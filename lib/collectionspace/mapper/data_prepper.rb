# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataPrepper
      attr_reader :data, :handler, :config, :cache, :client
      attr_accessor :response, :xphash

      def initialize(data, handler)
        @handler = handler
        @config = @handler.mapper.batchconfig
        @cache = @handler.mapper.termcache
        @client = @handler.mapper.csclient
        @response = CollectionSpace::Mapper.setup_data(data, @config)
        drop_empty_fields
        process_xpaths if @response.valid?
      end

      def prep
        split_data
        transform_data
        transform_date_fields
        handle_term_fields
        @response.terms.flatten!
        check_data
        combine_data_fields
        self
      end

      def split_data
        @xphash.each{ |_xpath, hash| do_splits(hash) }
        @response.split_data
      end

      def transform_data
        @xphash.each{ |_xpath, hash| do_transforms(hash) }
        @response.transformed_data
      end

      def transform_date_fields
        @xphash.each{ |xpath, hash| do_date_transforms(xpath, hash) }
        @response.transformed_data
      end

      def handle_term_fields
        @xphash.each{ |_xpath, hash| do_term_handling(hash) }
        @response.warnings.flatten!
        @response.errors.flatten!
        @response.transformed_data
      end

      def check_data
        @xphash.each{ |_xpath, hash| check_data_quality(hash) }
        @response.warnings.flatten!
        @response.warnings
      end

      def combine_data_fields
        @xphash.each{ |xpath, hash| combine_data_values(xpath, hash) }
        @response.combined_data
      end

      private

      # used by NonHierarchicalRelationshipPrepper and AuthorityHierarchyPrepper
      def push_errors_and_warnings
        unless errors.empty?
          @response.errors << errors
          @response.errors.flatten!
        end
        unless warnings.empty?
          @response.warnings << warnings
          @response.warnings.flatten!
        end
      end

      def drop_empty_fields
        @response.merged_data = @response.merged_data.delete_if{ |_k, v| v.blank? }
      end

      def process_xpaths
        # keep only mappings for datacolumns present in data hash
        mappings = @handler.mapper.mappings.select do |mapper|
          mapper.fieldname == 'shortIdentifier' || @response.merged_data.key?(mapper.datacolumn)
        end

        # create xpaths for remaining mappings...
        @xphash = mappings.map{ |mapper| mapper.fullpath }.uniq
        # hash with xpath as key and xpath info hash from DataHandler as value
        @xphash = @xphash.map{ |xpath| [xpath, @handler.mapper.xpath[xpath].clone] }.to_h
        @xphash.each do |_xpath, hash|
          hash[:mappings] = hash[:mappings].select do |mapping|
            mapping.fieldname == 'shortIdentifier' || @response.merged_data.key?(mapping.datacolumn)
          end
        end
      end

      def identifier?(column)
        column.downcase == handler.mapper.config.identifier_field.downcase
      end

      def do_splits(xphash)
        if xphash[:is_group] == false
          do_non_group_splits(xphash)
        elsif xphash[:is_group] == true && xphash[:is_subgroup] == false
          do_non_subgroup_group_splits(xphash)
        elsif xphash[:is_group] && xphash[:is_subgroup]
          do_subgroup_splits(xphash)
        end
      end

      def do_non_group_splits(xphash)
        xphash[:mappings].each do |mapping|
          column = mapping.datacolumn
          data = @response.merged_data.fetch(column, nil)
          next if data.nil? || data.empty?

          @response.split_data[column] = non_group_splitter(mapping, data)
          # mapping.repeats == 'y' ? CollectionSpace::Mapper::SimpleSplitter.new(data, config).result : [data.strip]
        end
      end

      def non_group_splitter(mapping, data)
        return CollectionSpace::Mapper::SimpleSplitter.new(data, config).result if mapping.repeats == 'y'
        return split_identifier(data) if identifier?(mapping.fieldname)

        [data.strip]
      end

      def split_identifier(data)
        return [data.strip] if config.strip_id_values

        [data]
      end

      def do_non_subgroup_group_splits(xphash)
        xphash[:mappings].each do |mapping|
          column = mapping.datacolumn
          data = @response.merged_data.fetch(column, nil)
          next if data.nil? || data.empty?

          @response.split_data[column] = CollectionSpace::Mapper::SimpleSplitter.new(data, config).result
        end
      end

      def do_subgroup_splits(xphash)
        xphash[:mappings].each do |mapping|
          column = mapping.datacolumn
          data = @response.merged_data.fetch(column, nil)
          next if data.nil? || data.empty?

          @response.split_data[column] = CollectionSpace::Mapper::SubgroupSplitter.new(data, config).result
        end
      end

      def do_transforms(xphash)
        splitdata = @response.split_data
        targetdata = @response.transformed_data
        xphash[:mappings].each do |mapping|
          column = mapping.datacolumn
          data = splitdata.fetch(column, nil)
          next if data.blank?

          targetdata[column] = if mapping.transforms.blank?
                                 data
                               else
                                 data.map do |d|
                                   if d.is_a?(String)
                                     transform_value(d, mapping.transforms, column)
                                   else
                                     d.map{ |val| transform_value(val, mapping.transforms, column) }
                                   end
                                 end
                               end
        end
      end

      def transform_value(value, transforms, column)
        vt = CollectionSpace::Mapper::ValueTransformer.new(value, transforms, self)
        unless vt.warnings.empty?
          vt.warnings.each{ |w| w[:field] = column }
          @response.warnings << vt.warnings
        end
        unless vt.errors.empty?
          vt.errors.each{ |e| e[:field] = column }
          @response.errors << vt.errors
        end
        vt.result
      end

      def do_date_transforms(_xpath, xphash)
        sourcedata = @response.transformed_data

        xphash[:mappings].each do |mapping|
          column = mapping.datacolumn
          type = mapping.data_type

          data = sourcedata.fetch(column, nil)
          next if data.blank?

          if type['date']
            case type
            when 'structured date group'
              sourcedata[column] = structured_date_transform(data)
            when 'date'
              sourcedata[column] = unstructured_date_transform(data)
            end
          else
            sourcedata[column] = data
          end
        end
      end

      def do_term_handling(xphash)
        sourcedata = @response.transformed_data
        xphash[:mappings].each do |mapping|
          source_type = get_source_type(mapping.source_type)
          next if source_type.nil?

          column = mapping.datacolumn
          next if column['refname']

          data = sourcedata.fetch(column, nil)
          next if data.blank?

          th = CollectionSpace::Mapper::TermHandler.new(mapping: mapping,
                                                        data: data,
                                                        client: @client,
                                                        cache: @cache,
                                                        mapper: @handler.mapper)
          @response.transformed_data[column] = th.result
          @response.terms << th.terms
          @response.warnings << th.warnings unless th.warnings.empty?
          @response.errors << th.errors unless th.errors.empty?
        end
      end

      def get_source_type(source_type_string)
        case source_type_string
        when 'authority'
          source_type_string.to_sym
        when 'vocabulary'
          source_type_string.to_sym
        end
      end

      def structured_date_transform(data)
        data.map do |d|
          if d.is_a?(String)
            CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(d,
                                                                  @client,
                                                                  @cache,
                                                                  @handler.mapper.batchconfig).mappable
          else
            d.map do |v|
              CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(v,
                                                                    @client,
                                                                    @cache,
                                                                    @handler.mapper.batchconfig).mappable
            end
          end
        end
      end

      def unstructured_date_transform(data)
        data.map do |d|
          if d.is_a?(String)
            CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(d,
                                                                  @client,
                                                                  @cache,
                                                                  @handler.mapper.batchconfig).stamp
          else
            d.map do |v|
              CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(v,
                                                                    @client,
                                                                    @cache,
                                                                    @handler.mapper.batchconfig).stamp
            end
          end
        end
      end

      def check_data_quality(xphash)
        xformdata = @response.transformed_data
        xphash[:mappings].each do |mapping|
          data = xformdata[mapping.datacolumn]
          next if data.blank?

          qc = CollectionSpace::Mapper::DataQualityChecker.new(mapping, data)
          @response.warnings << qc.warnings unless qc.warnings.empty?
        end
      end

      def combine_data_values(xpath, xphash)
        @response.combined_data[xpath] = {}
        fieldhash = {} # key = CSpace field names; value = array of data columns mapping to that field
        # create keys in fieldname and combined_data for all CSpace fields represented in data
        xphash[:mappings].each do |mapping|
          fieldname = mapping.fieldname
          unless fieldhash.key?(fieldname)
            @response.combined_data[xpath][fieldname] = []
            fieldhash[fieldname] = []
          end
          fieldhash[fieldname] << mapping.datacolumn
        end

        xform = @response.transformed_data
        fieldhash.each do |field, cols|
          case cols.length
          when 0
            next
          when 1
            @response.combined_data[xpath][field] = xform[cols[0]]
          else
            xformed = cols.map{ |col| xform[col] }.compact
            chk = []
            xformed.each{ |arr| chk << arr.map{ |e| e.class } }
            chk = chk.flatten.uniq
            if chk == [String]
              @response.combined_data[xpath][field] = xformed.flatten
            elsif chk == [Array]
              @response.combined_data[xpath][field] = combine_subgroup_values(xformed)
            elsif chk.empty?
              next
            else
              raise StandardError, 'Mixed class types in multi-authority field set'
            end
          end
        end

        @response.combined_data[xpath].select{ |_fieldname, val| val.blank? }.keys.each do |fieldname|
          @response.combined_data[xpath].delete(fieldname)
          unless fieldname == 'shortIdentifier'
            @xphash[xpath][:mappings].delete_if{ |mapping| mapping.fieldname == fieldname }
          end
        end
      end

      def combine_subgroup_values(data)
        combined = []
        group_count = data.map(&:length).uniq.sort.last
        group_count.times{ combined << [] }
        data.each do |field|
          field.each_with_index do |valarr, i|
            valarr.each{ |e| combined[i] << e }
          end
        end
        combined
      end
    end
  end
end

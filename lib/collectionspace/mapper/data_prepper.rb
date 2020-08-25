# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataPrepper
      ::DataPrepper = CollectionSpace::Mapper::DataPrepper
      attr_reader :data, :handler, :config, :xphash
      attr_accessor :response
      def initialize(data_hash, handler, response = nil)
        @response = response.nil? ? Response.new(data_hash) : response
        @data = data_hash.transform_keys(&:downcase)
        @handler = handler
        @config = handler.config
        @cache = @handler.cache
        @response.merged_data = merge_default_values
        process_xpaths
      end

      def prep
        split_data
        transform_data
        transform_date_fields
        check_data
        combine_data_fields
        @response
      end
      
      def split_data
        @xphash.each{ |xpath, hash| do_splits(xpath, hash) }
        @response.split_data
      end

      def transform_data
        @xphash.each{ |xpath, hash| do_transforms(xpath, hash) }
        @response.transformed_data
      end

      def transform_date_fields
        @xphash.each{ |xpath, hash| do_date_transforms(xpath, hash) }
        @response.transformed_data
      end
      
      def check_data
        @xphash.each{ |xpath, hash| check_data_quality(xpath, hash) }
        @response.warnings.flatten!
        @response.warnings
      end

      def combine_data_fields
        @xphash.each{ |xpath, hash| combine_data_values(xpath, hash) }
        @response.combined_data
      end

      private

      def merge_default_values
        mdata = @data.clone
        @handler.defaults.each do |f, val|
          if @config[:force_defaults]
            mdata[f] = val
          else
            dataval = @data.fetch(f, nil)
            mdata[f] = val if dataval.nil? || dataval.empty?
          end
        end
        mdata.compact
      end

      def process_xpaths
        # keep only mappings for datacolumns present in data hash
        mappings = @handler.mapper[:mappings].select{ |m| @response.merged_data.keys.include?(m[:datacolumn]) }
        # create xpaths for remaining mappings...
        @xphash = mappings.map{ |m| m[:fullpath] }.uniq
        # hash with xpath as key and xpath info hash from DataHandler as value
        @xphash = @xphash.map{ |xpath| [xpath, @handler.mapper[:xpath][xpath]] }.to_h
        @xphash.each{ |xpath, hash| hash[:mappings] = hash[:mappings]
            .select{ |m| @response.merged_data.keys.include?(m[:datacolumn]) } }
      end

      def do_splits(xpath, xphash)
        if xphash[:is_group] == false
          xphash[:mappings].each do |mapping|
            column = mapping[:datacolumn]
            data = @response.merged_data.fetch(column, nil)
            next if data.nil? || data.empty?
            @response.split_data[column] = mapping[:repeats] == 'y' ? SimpleSplitter.new(data, @config).result : [data.strip]
          end
        elsif xphash[:is_group] == true && xphash[:is_subgroup] == false
          xphash[:mappings].each do |mapping|
            column = mapping[:datacolumn]
            data = @response.merged_data.fetch(column, nil)
            next if data.nil? || data.empty?
            @response.split_data[column] = SimpleSplitter.new(data, @config).result
          end
        elsif xphash[:is_group] && xphash[:is_subgroup]
          xphash[:mappings].each do |mapping|
            column = mapping[:datacolumn]
            data = @response.merged_data.fetch(column, nil)
            next if data.nil? || data.empty?
            @response.split_data[column] = SubgroupSplitter.new(data, @config).result
          end
        end
      end

      def do_transforms(xpath, xphash)
        splitdata = @response.split_data
        targetdata = @response.transformed_data
        xphash[:mappings].each do |mapping|
          column = mapping[:datacolumn]
          data = splitdata.fetch(column, nil)
          next if data.blank?
          if mapping[:transforms].blank?
            targetdata[column] = data
          else
            targetdata[column] = data.map do |d|
              if d.is_a?(String)
                ValueTransformer.new(d, mapping[:transforms], @cache).result
              else
                d.map{ |val| ValueTransformer.new(val, mapping[:transforms], @cache).result}
              end
            end
          end
        end
      end

      def do_date_transforms(xpath, xphash)
        sourcedata = @response.transformed_data

        xphash[:mappings].each do |mapping|
          column = mapping[:datacolumn]
          type = mapping[:data_type]
          
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

      def structured_date_transform(data)
        data.map do |d|
          if d.is_a?(String)
            CspaceDate.new(d, @handler.client, @handler.cache, @config).mappable
          else
            d.map{ |v| CspaceDate.new(v, @handler.client, @handler.cache, @config).mappable }
          end
        end
      end

      def unstructured_date_transform(data)
        data.map do |d|
          if d.is_a?(String)
            CspaceDate.new(d, @handler.client, @handler.cache, @config).stamp
          else
            d.map{ |v| CspaceDate.new(v, @handler.client, @handler.cache, @config).stamp }
          end
        end
      end

      def check_data_quality(xpath, xphash)
        xformdata = @response.transformed_data
        xphash[:mappings].each do |mapping|
          data = xformdata[mapping[:datacolumn]]
          next if data.blank?
          qc = DataQualityChecker.new(mapping, data)
          @response.warnings << qc.warnings unless qc.warnings.empty?
        end
      end

      def combine_data_values(xpath, xphash)
        fieldhash = {} # key = CSpace field names; value = array of data columns mapping to that field
        # create keys in fieldname and combined_data for all CSpace fields represented in data
        xphash[:mappings].each do |mapping|
          fieldname = mapping[:fieldname]
          @response.combined_data[fieldname] = []
          fieldhash[fieldname] = []
        end
        
        xphash[:mappings].each do |mapping|
          fieldname = mapping[:fieldname]
          col = mapping[:datacolumn]
          fieldhash[fieldname] << col
        end
        
        xform = @response.transformed_data
        fieldhash.each do |field, cols|
          cols.each{ |col| xform[col].each{ |v| @response.combined_data[field] << v } }
        end
      end
    end
  end
end
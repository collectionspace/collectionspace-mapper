# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataPrepper

      # @param data [Hash, CollectionSpace::Mapper::Response]
      # @param handler [CollectionSpace::Mapper::DataHandler]
      def initialize(data, handler)
        @handler = handler
        @splitter = handler.data_splitter
        @response = CollectionSpace::Mapper::Response.new(data, handler)
      end

      def prep
        split_data
        transform_data
        transform_date_fields
        handle_term_fields
        check_data
        combine_data_fields
        response
      end

      private

      attr_reader :data, :handler, :splitter, :response, :date_handler

      def split_data
        response.xpaths.values.each{ |xpath| do_splits(xpath) }
      end

      def transform_data
        response.xpaths.values.each { |xpath| do_transforms(xpath) }
      end

      def transform_date_fields
        response.xpaths.values.each { |xpath| do_date_transforms(xpath) }
      end

      def handle_term_fields
        response.xpaths.values.each { |xpath| do_term_handling(xpath) }
      end

      def check_data
        response.xpaths.values.each { |xpath| check_data_quality(xpath) }
      end

      def combine_data_fields
        response.xpaths.values.each { |xpath| combine_data_values(xpath) }
      end

      # used by NonHierarchicalRelationshipPrepper and AuthorityHierarchyPrepper
      def push_errors_and_warnings
        response.add_error(errors) unless errors.empty?
        response.add_error(warnings) unless warnings.empty?
      end

      def identifier?(column)
        column.downcase == handler.record.identifier_field.downcase
      end

      # @param xpath [CollectionSpace::Mapper::Xpath]
      def do_splits(xpath)
        if xpath.is_group? == false
          do_non_group_splits(xpath)
        elsif xpath.is_group? == true && xpath.is_subgroup? == false
          do_non_subgroup_group_splits(xpath)
        elsif xpath.is_group? && xpath.is_subgroup?
          do_subgroup_splits(xpath)
        end
      end

      # @param xpath [CollectionSpace::Mapper::Xpath]
      def do_non_group_splits(xpath)
        xpath.mappings.each do |mapping|
          column = mapping.datacolumn
          data = response.merged_data.fetch(column, nil)
          next if data.nil? || data.empty?

          response.split_data[column] = non_group_splitter(mapping, data)
        end
      end

      def non_group_splitter(mapping, data)
        if mapping.repeats == "y"
          splitter.call(data, :simple)
        elsif identifier?(mapping.fieldname)
          split_identifier(data)
        else
          [data.strip]
        end
      end

      def split_identifier(data)
        return [data.strip] if handler.batch.strip_id_values

        [data]
      end

      def do_non_subgroup_group_splits(xpath)
        xpath.mappings.each do |mapping|
          column = mapping.datacolumn
          data = response.merged_data[column]
          next if data.nil? || data.empty?

          response.split_data[column] = splitter.call(data, :simple)
        end
      end

      def do_subgroup_splits(xpath)
        xpath.mappings.each do |mapping|
          column = mapping.datacolumn
          data = response.merged_data[column]
          next if data.nil? || data.empty?

          response.split_data[column] = splitter.call(data, :subgroup)
        end
      end

      def do_transforms(xpath)
        xpath.mappings.each do |mapping|
          column = mapping.datacolumn
          transforms = mapping.transforms.dup
          transforms.delete(:vocabulary)
          transforms.delete(:authority)

          data = response.split_data[column]
          if data.nil? || data.empty?
            next
          elsif transforms.empty?
            response.transformed_data[column] = data
          else
            response.transformed_data[column] = transform_all_values(
              mapping,
              data
            )
          end
        end
      end

      def transform_all_values(mapping, data)
        if data.first.is_a?(String)
          transform_values(mapping, data)
        else
          data.map{ |vals| transform_values(mapping, vals) }
        end
      end

      def transform_values(mapping, data)
        data.map { |val| transform(mapping, val) }
      end

      def transform(mapping, value)
        CollectionSpace::Mapper::ValueTransformer.call(
          value: value,
          mapping: mapping,
          handler: handler,
          response: response
        )
      end

      def do_date_transforms(xpath)
        sourcedata = response.transformed_data
        xpath.mappings.each do |mapping|
          type = mapping.data_type
          next unless type["date"]

          column = mapping.datacolumn
          data = sourcedata[column]
          next if data.blank?


          subgroup = !data.first.is_a?(String)

          csdates = [data].flatten
            .map do |dateval|
              CollectionSpace::Mapper::Dates::CspaceDate.new(dateval, handler)
            end


          case type
          when "structured date group"
            datevals = map_structured_dates(csdates, column)
          when "date"
            datevals = map_unstructured_dates(csdates, column)
          end

          val = subgroup ? [datevals] : datevals
          sourcedata[column] = val
        end
      end

      def map_structured_dates(csdates, column)
        csdates.map do |csd|
          result = csd.mappable
        rescue CollectionSpace::Mapper::UnparseableStructuredDateError => err
          err.set_column(column)
          response.add_warning(err.to_h)
          err.mappable
        else
          result
        end
      end

      def map_unstructured_dates(csdates, column)
        csdates.map do |csd|
          result = csd.stamp
        rescue CollectionSpace::Mapper::UnparseableDateError => err
          err.set_column(column)
          response.add_error(err.to_h)
          ""
        else
          result
        end
      end

      def do_term_handling(xpath)
        sourcedata = response.transformed_data
        xpath.mappings.each do |mapping|
          source_type = get_source_type(mapping.source_type)
          next if source_type.nil?

          column = mapping.datacolumn
          next if column["refname"]

          data = sourcedata.fetch(column, nil)
          next if data.blank?

          CollectionSpace::Mapper::TermHandler.new(
            mapping: mapping,
            data: data,
            handler: handler,
            response: response
          )
        end
      end

      def get_source_type(source_type_string)
        case source_type_string
        when "authority"
          source_type_string.to_sym
        when "vocabulary"
          source_type_string.to_sym
        end
      end

      def check_data_quality(xphash)
        xphash.mappings.each do |mapping|
          next unless CollectionSpace::Mapper::DataQualityChecker.checkable?(
            mapping
          )

          data = response.transformed_data[mapping.datacolumn]
          next if data.blank?

          CollectionSpace::Mapper::DataQualityChecker.new(
            mapping,
            data,
            response
          )
        end
      end

      def create_combined_data_xpath_structure(xpath, fields)
        response.combined_data[xpath.path] = {}
        fields.keys
          .each{ |field| response.combined_data[xpath.path][field] = [] }
      end

      def initially_populate_combined_data(xpath, fields)
        xform = response.transformed_data

        fields.each do |field, cols|
            xformed = cols.map{ |col|
              xform[col.datacolumn.downcase]
            }.compact
            chk = []
            xformed.each { |arr| chk << arr.map { |e| e.class } }
            chk = chk.flatten.uniq
            if chk == [String] || chk == [Hash]
              response.combined_data[xpath.path][field] = xformed.flatten
            elsif chk == [Array]
              response.combined_data[xpath.path][field] =
                combine_subgroup_values(xformed)
            elsif chk == [NilClass] || chk.empty?
              next
            else
              raise StandardError,
                "Mixed class types in multi-column field set"
            end
        end
      end

      def clean_combined_data(xpath)
        response.combined_data[xpath.path].select { |_fieldname, val|
          val.blank?
        }.keys.each do |fieldname|
          response.combined_data[xpath.path].delete(fieldname)
          unless fieldname == "shortIdentifier"
            xpath.mappings.delete_if { |mapping|
              mapping.fieldname == fieldname
            }
          end
        end
      end

      def combine_data_values(xpath)
        fields = xpath.mappings.group_by(&:fieldname)
        create_combined_data_xpath_structure(xpath, fields)
        initially_populate_combined_data(xpath, fields)
        clean_combined_data(xpath)
      end

      def combine_subgroup_values(data)
        combined = []
        group_count = data.map(&:length).uniq.max
        group_count.times { combined << [] }
        data.each do |field|
          field.each_with_index do |valarr, i|
            valarr.each { |e| combined[i] << e }
          end
        end
        combined
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module DateDetails
      class DataPrepper < CollectionSpace::Mapper::DataPrepper
        include CollectionSpace::Mapper::TermSearchable

        # @param data [Hash, CollectionSpace::Mapper::Response]
        def initialize(data, handler)
          super
          @id_field = handler.record.identifier_field.downcase
          @target = response.merged_data["date_field_group"].downcase
          @target_mapping = handler.record.mappings.lookup(target.downcase)
          @date_fields = CollectionSpace::Mapper.structured_date_detailed_fields
            .map(&:downcase)
          @date_field_lookup =
            CollectionSpace::Mapper.structured_date_detailed_fields
              .map { |field| [field.downcase, field] }
              .to_h
          @grouped_data = nil
        end

        def prep
          unless handler.grouped_fields
            handler.check_fields(response.merged_data)
          end
          if handler.grouped_handler
            extract_grouped_data
            grouped_prepped = handler.grouped_handler.prep(grouped_data)
          end
          split_data
          transform_data
          handle_term_fields
          extract_date_fields
          clean_transformed
          readd_id
          combine_data_fields
          merge_grouped_data(grouped_prepped) if grouped_data
          response
        end

        private

        attr_reader :id_field, :target, :target_mapping, :date_fields,
          :date_field_lookup, :grouped_data

        def date_data
          @date_data ||= response.merged_data
            .select { |field, _value| date_fields.any?(field) }
        end

        def non_date_data
          @non_date_data ||= response.merged_data
            .reject { |field, _value| date_fields.any?(field) }
        end

        def extract_grouped_data
          @grouped_data = {}
          copy_id_field_to_grouped_data
          move_grouped_fields_to_grouped_data
        end

        def copy_id_field_to_grouped_data
          if response.merged_data.key?(id_field)
            grouped_data[id_field] = response.merged_data[id_field]
          elsif response.merged_data.key?("termdisplayname")
            grouped_data["termdisplayname"] =
              response.merged_data["termdisplayname"]
          end
        end

        def move_grouped_fields_to_grouped_data
          handler.grouped_fields.each do |field|
            grouped_data[field] = response.merged_data[field]
            response.merged_data.delete(field)
          end
        end

        def split_data
          response.merged_data.each do |field, val|
            splitval = if identifier?(field)
              split_identifier(val)
            else
              splitter.call(val, :simple)
            end
            response.split_data[field] = splitval

            next if non_date_data.keys.any?(field)
            response.transformed_data[field] = splitval
          end
        end

        def transform_data
          response.transformed_data.each do |field, data|
            mapping = handler.record.mappings
              .lookup(field)
            next unless mapping

            response.transformed_data[field] = transform_all_values(
              mapping,
              data
            )
          end
        end

        def handle_term_fields
          response.transformed_data.each do |field, data|
            mapping = handler.record.mappings
              .lookup(field)
            next unless mapping
            next unless mapping.source_type
            next if mapping.source_type == "optionlist"
            next if data.nil? || data.empty?

            CollectionSpace::Mapper::TermHandler.new(
              mapping: mapping,
              data: data,
              handler: handler,
              response: response
            )
          end
        end

        def extract_date_fields
          lengths = date_field_lengths
          if lengths.length == 1
            max = lengths[0]
          else
            max = lengths.max
            response.add_warning("Uneven field group values in date details "\
                                 "for #{target}. Data may map unexpectedly.")
          end

          response.transformed_data[target] = extract_dates(max)
        end

        def date_field_lengths
          response.transformed_data.values
            .map(&:length)
            .uniq
        end

        def extract_dates(max)
          dates = []
          index = 0
          max.times do
            dates << capitalized_fieldnames(extracted_date(index))
            index += 1
          end
          dates
        end

        def extracted_date(index)
          response.transformed_data.map do |field, values|
            [field, values[index]]
          end.to_h
            .compact
        end

        def capitalized_fieldnames(datehash)
          datehash.transform_keys! { |key| date_field_lookup[key] }
        end

        def clean_transformed
          response.transformed_data
            .delete_if { |field, _val| date_data.keys.any?(field) }
        end

        def readd_id
          id = case id_field
          when "shortidentifier"
            [authority_short_id]
          else
            response.split_data[id_field]
          end
          response.transformed_data[id_field] = id
        end

        def authority_short_id
          term = response.split_data["termdisplayname"][0]
          CollectionSpace::Mapper::Identifiers::AuthorityShortIdentifier.call(
            term
          )
        end

        def merge_grouped_data(grouped_prepped)
          path = handler.target_path

          response.combined_data[path].merge!(
            grouped_prepped.combined_data[path]
          )
          grouped_prepped.errors.each { |err| response.add_error(err) }
          grouped_prepped.terms.each { |term| response.add_term(term) }
          grouped_prepped.warnings.each do |warning|
            response.add_warning(warning)
          end
        end
      end
    end
  end
end

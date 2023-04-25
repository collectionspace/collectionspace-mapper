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
              .map{ |field| [field.downcase, field] }
              .to_h
        end

        def prep
          split_data
          transform_data
          handle_term_fields
          extract_date_fields
          clean_transformed
          readd_id
          combine_data_fields
          response
        end

        private

        attr_reader :id_field, :target, :target_mapping, :date_fields,
          :date_field_lookup

        def date_data
          @date_data ||= response.merged_data
            .select{ |field, _value| date_fields.any?(field) }
        end

        def non_date_data
          @non_date_data ||= response.merged_data
            .reject{ |field, _value| date_fields.any?(field) }
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
          response.transformed_data.map{ |field, values|
            [field, values[index]]
          }.to_h
            .compact
        end

        def capitalized_fieldnames(datehash)
          datehash.transform_keys!{ |key| date_field_lookup[key] }
        end

        def clean_transformed
          response.transformed_data
            .delete_if{ |field, _val| date_data.keys.any?(field) }
        end

        def readd_id
          response.transformed_data[id_field] =
            response.split_data[id_field]
        end
      end
    end
  end
end
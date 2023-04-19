# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"

module CollectionSpace
  module Mapper
    module DateDetails
      class Handler < CollectionSpace::Mapper::HandlerFullRecord
        private

        def pre_initialize
          config.batch_mode = "date details"
        end

        def get_prepper_class
          CollectionSpace::Mapper::DateDetails::DataPrepper
        end

        def get_date_handler
          nil
        end

        def known_fields
          [
            record.identifier_field,
            "date_field_group",
            CollectionSpace::Mapper.structured_date_detailed_fields
          ].flatten
            .map(&:downcase)
        end
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class UnparseableStructuredDateError < CollectionSpace::Mapper::Error
        attr_reader :date_string, :mappable
        attr_accessor :column

        def initialize(date_string:, orig_err: nil, mappable:, desc: nil)
          @date_string = date_string
          @orig_err = orig_err
          @mappable = mappable
          @desc = desc
          super
        end

        def to_h
          {
            category: :unparseable_structured_date,
            field: column,
            value: date_string,
            message: message
          }
        end

        private

        attr_reader :orig_err, :desc

        def message
          base = "Unparseable structured date "\
            "in #{column}: `#{date_string}`"
        end

        def message_from_err
          return nil unless orig_err

          orig_err.message
        end
      end
    end
  end
end

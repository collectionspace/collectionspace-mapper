# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class UnparseableDateError < CollectionSpace::Mapper::Error
        attr_reader :date_string
        attr_accessor :column
        def initialize(date_string)
          @date_string = date_string
          super
        end

        def to_h
          {
            category: :unparseable_date,
            field: column,
            value: date_string,
            message: message
          }
        end

        def message
          "Unparseable date value in #{column}: `#{date_string}`"
        end
      end
    end
  end
end

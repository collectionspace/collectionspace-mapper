# frozen_string_literal: true

require "chronic"

module CollectionSpace
  module Mapper
    module Dates
      extend self

      class CspaceDate
        attr_reader :date_string, :date_handler

        # @param date_string [String] to parse
        # @param handler [CollectionSpace::Mapper::Dates::StructuredDateHandler]
        def initialize(
          date_string,
          date_handler = CollectionSpace::Mapper.date_handler
        )
          @date_handler = date_handler
          @date_string = date_string

          @date = date_handler.call(date_string)
        end

        def mappable
          date.mappable
        end

        def stamp
          date.stamp
        end

        private

        attr_reader :date
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      extend self

      class CspaceDate
        # @param date_string [String] to parse
        # @param handler [CollectionSpace::Mapper::DataHandler]
        def initialize(date_string, handler)
          @date_handler = handler.date_handler
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

        attr_reader :date_string, :date_handler, :date
      end
    end
  end
end

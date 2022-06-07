# frozen_string_literal: true

require 'chronic'

module CollectionSpace
  module Mapper
    module Dates
      class ChronicParser
        include CollectionSpace::Mapper::Dates::Mappable
        
        attr_reader :mappable
        def initialize(date_string, handler)
          @date_string = date_string
          @handler = handler
          parsed = parse
          return CollectionSpace::Mapper::Dates::ServicesParser.new(date_string, handler) unless parsed

          @mappable = map_timestamp(parsed)
          self
        end

        private
        
        attr_reader :date_string, :handler
        
        def day_month_year?
          handler.config.date_format == 'day month year'
        end

        def parse
          return Chronic.parse(date_string, endian_precedence: :little) if day_month_year?

          Chronic.parse(date_string)
        end

      end
    end
  end
end

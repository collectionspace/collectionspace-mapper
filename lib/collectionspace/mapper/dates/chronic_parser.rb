# frozen_string_literal: true

require 'chronic'

module CollectionSpace
  module Mapper
    module Dates
      class ChronicParser
        include CollectionSpace::Mapper::Dates::Mappable

        def initialize(date_string, handler)
          @date_string = date_string
          @handler = handler
          self
        end

        def mappable
          parsed = parse
          if parsed.nil?
            result = ServicesParser.new(date_string, handler).mappable
          else
            result = map_timestamp(parsed)
          end
        rescue StandardError => err
          fail UnparseableStructuredDateError.new(
            date_string: date_string,
            orig_err: err,
            mappable: no_mappable_date
          )
        else
          result
        end

        private

        attr_reader :date_string, :handler

        def day_month_year?
          handler.config.date_format == 'day month year'
        end

        def parse
          if day_month_year?
            Chronic.parse(date_string, endian_precedence: :little)
          else
            Chronic.parse(date_string)
          end
        end
      end
    end
  end
end

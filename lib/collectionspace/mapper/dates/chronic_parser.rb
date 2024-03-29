# frozen_string_literal: true

require "chronic"

module CollectionSpace
  module Mapper
    module Dates
      class ChronicParser
        include CollectionSpace::Mapper::Dates::Mappable

        # @param date_string [String] to parse
        # @param handler [CollectionSpace::Mapper::DataHandler]
        def initialize(date_string, handler)
          @date_string = date_string
          @handler = handler
        end

        def mappable
          parsed = parse
          result = if parsed.nil?
            ServicesParser.new(date_string, handler).mappable
          else
            map_timestamp(parsed)
          end
        rescue => err
          fail CollectionSpace::Mapper::UnparseableStructuredDateError.new(
            date_string: date_string,
            orig_err: err,
            mappable: no_mappable_date
          )
        else
          result
        end

        private

        attr_reader :date_string, :handler

        def parse
          if day_month_year?
            Chronic.parse(date_string, endian_precedence: :little)
          else
            Chronic.parse(date_string)
          end
        end

        def day_month_year?
          handler.batch.date_format == "day month year"
        end
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class TwoDigitYearHandler
        include CollectionSpace::Mapper::Dates::Mappable

        def initialize(date_string, handler, year_handling)
          @date_string = date_string
          @handler = handler
          @year_handling = year_handling
          self
        end

        def mappable
          case year_handling
          when "literal"
            literal_mappable
          when "coerce"
            coerced_mappable
          else
            fail UnparseableStructuredDateError.new(
              date_string: date_string,
              mappable: no_mappable_date
            )
          end
        end

        private

        attr_reader :date_string, :handler, :year_handling

        def coerced_mappable
          result = CollectionSpace::Mapper::Dates::ChronicParser.new(
            coerced_year_date, handler
          ).mappable
          result["dateDisplayDate"] = date_string
          result
        rescue UnparseableStructuredDateError => err
          raise err
        end

        def coerced_year_date
          val = date_string.tr("/", "-").split("-")
          yr = val.pop
          this_year = Time.now.year.to_s
          this_year_century = this_year[0, 2]
          this_year_last_two = this_year[2, 2].to_i

          val << if yr.to_i > this_year_last_two
            "#{this_year_century.to_i - 1}#{yr}"
          else
            "#{this_year_century}#{yr}"
          end
          val.join("-")
        end

        def literal_mappable
          CollectionSpace::Mapper::Dates::ServicesParser.new(
            date_string, handler
          ).mappable
        rescue UnparseableStructuredDateError => err
          raise err
        end
      end
    end
  end
end

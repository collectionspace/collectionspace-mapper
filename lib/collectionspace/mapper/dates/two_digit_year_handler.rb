# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class TwoDigitYearHandler
        include CollectionSpace::Mapper::Dates::Mappable

        # @param date_string [String] to parse
        # @param handler [CollectionSpace::Mapper::DataHandler]
        def initialize(date_string, handler)
          @date_string = date_string
          @handler = handler
          @year_handling = handler.batch.two_digit_year_handling
        end

        def mappable
          case year_handling
          when "literal"
            literal_mappable
          when "coerce"
            coerced_mappable
          end
        end

        private

        attr_reader :date_string, :handler, :year_handling

        def coerced_mappable
          result = CollectionSpace::Mapper::Dates::ChronicParser.new(
            coerced_year_date,
            handler
          ).mappable
          result["dateDisplayDate"] = date_string
          result
        rescue => err
          fail CollectionSpace::Mapper::UnparseableStructuredDateError.new(
            date_string: date_string,
            orig_err: err,
            mappable: nil
          )
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
            date_string,
            handler
          ).mappable
        rescue => err
          fail CollectionSpace::Mapper::UnparseableStructuredDateError.new(
            date_string: date_string,
            orig_err: err,
            mappable: nil
          )
        end
      end
    end
  end
end

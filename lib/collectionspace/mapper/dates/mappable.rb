# frozen_string_literal: true

require 'chronic'

module CollectionSpace
  module Mapper
    module Dates
      module Mappable

        TIMESTAMP_SUFFIX = 'T00:00:00.000Z'

        def add_timestamp_to_scalar_values(maphash)
          maphash.map do |key, val|
            next [key, val] unless key.end_with?('ScalarValue')
            next [key, val] if val.end_with?('Z')

            [key, "#{val}#{TIMESTAMP_SUFFIX}"]
          end.to_h
        end

        def map_timestamp(timestamp)
          date = timestamp.to_date
          next_day = date + 1

          maphash = {
            'dateDisplayDate' => date_string,
            'dateEarliestSingleYear' => date.year.to_s,
            'dateEarliestSingleMonth' => date.month.to_s,
            'dateEarliestSingleDay' => date.day.to_s,
            'dateEarliestSingleEra' => handler.ce,
            'dateEarliestScalarValue' => date.iso8601,
            'dateLatestScalarValue' => next_day.iso8601,
            'scalarValuesComputed' => 'true'
          }
          add_timestamp_to_scalar_values(maphash)
        end

        def no_mappable_date
          {
            'dateDisplayDate' => date_string,
            'scalarValuesComputed' => 'false',
            'dateNote' => 'date unparseable by batch import processor'
          }
        end

        def stamp
          desv = get_earliest_scalar
          if desv.blank?
            fail(UnparseableDateError.new(date_string))
          else
            desv
          end
        end

        def get_earliest_scalar
          mappable['dateEarliestScalarValue']
        rescue UnparseableStructuredDateError
          nil
        end
        private :get_earliest_scalar
      end
    end
  end
end

# frozen_string_literal: true

require 'chronic'

module CollectionSpace
  module Mapper
    module Dates
      module Mappable
        def map_timestamp(timestamp)
          date = timestamp.to_date
          next_day = date + 1

          {
            'dateDisplayDate' => date_string,
            'dateEarliestSingleYear' => date.year.to_s,
            'dateEarliestSingleMonth' => date.month.to_s,
            'dateEarliestSingleDay' => date.day.to_s,
            'dateEarliestSingleEra' => handler.ce,
            'dateEarliestScalarValue' => "#{date.iso8601}#{handler.timestamp_suffix}",
            'dateLatestScalarValue' => "#{next_day.iso8601}#{handler.timestamp_suffix}",
            'scalarValuesComputed' => 'true'
          }
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

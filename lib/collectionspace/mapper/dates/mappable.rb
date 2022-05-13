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
            'dateEarliestScalarValue' => "#{date.stamp(:db)}#{handler.timestamp_suffix}",
            'dateLatestScalarValue' => "#{next_day.stamp(:db)}#{handler.timestamp_suffix}",
            'scalarValuesComputed' => 'true'
          }
        end

        def no_mappable_date
          {
            'dateDisplayDate' => date_string,
            'scalarValuesComputed' => 'false'
          }
        end

        def stamp
          mappable['dateEarliestScalarValue'] ||= date_string
        end
      end
    end
  end
end


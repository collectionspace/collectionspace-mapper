# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class YearDateCreator
        include CS::Mapper::Dates::Mappable

        attr_reader :mappable
        
        def initialize(date_string, handler)
          @date_string = date_string
          @handler = handler
          @mappable = {
            'dateDisplayDate' => date_string,
            'dateEarliestSingleYear' => date_string,
            'dateEarliestSingleMonth' => '1',
            'dateEarliestSingleDay' => '1',
            'dateEarliestSingleEra' => handler.ce,
            'dateLatestYear' => date_string,
            'dateLatestMonth' => '12',
            'dateLatestDay' => '31',
            'dateLatestEra' => handler.ce,
            'dateEarliestScalarValue' => "#{date_string}-01-01#{handler.timestamp_suffix}",
            'dateLatestScalarValue' => "#{next_year}-01-01#{handler.timestamp_suffix}",
            'scalarValuesComputed' => 'true'
          }
          self
        end

        private
        
        attr_reader :date_string, :handler

        def next_year
          date_string.to_i + 1
        end
      end
    end
  end
end
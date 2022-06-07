# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class YearMonthDateCreator
        include CollectionSpace::Mapper::Dates::Mappable

        attr_reader :mappable
        
        def initialize(date_string, handler)
          @date_string = date_string
          @handler = handler
          @mappable = {
            'dateDisplayDate' => @date_string,
            'dateEarliestSingleYear' => year.to_s,
            'dateEarliestSingleMonth' => month.to_s,
            'dateEarliestSingleDay' => '1',
            'dateEarliestSingleEra' => handler.ce,
            'dateLatestYear' => year.to_s,
            'dateLatestMonth' => month.to_s,
            'dateLatestDay' => last_day_of_month.to_s,
            'dateLatestEra' => handler.ce,
            'dateEarliestScalarValue' => "#{year}-#{month.to_s.rjust(2, '0')}-01#{handler.timestamp_suffix}",
            'dateLatestScalarValue' => "#{year}-#{next_month.to_s.rjust(2, '0')}-01#{handler.timestamp_suffix}",
            'scalarValuesComputed' => 'true'
          }
          self
        end

        private
        
        attr_reader :date_string, :handler

        def last_day_of_month
          Date.new(year, month, -1).day
        end
        
        def month
          @month ||= date_string.sub(year.to_s, '').match(/(\d{1,2})/)[1].to_i
        end

        def next_month
          month + 1
        end
        
        def year
          @year ||= date_string.match(/(\d{4})/)[1].to_i
        end
      end
    end
  end
end

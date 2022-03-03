# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class DateBomber
        attr_reader :mappable, :stamp
        def initialize
          @mappable = {
            'dateDisplayDate' => THE_BOMB,
            'dateEarliestSingleYear' => THE_BOMB,
            'dateEarliestSingleMonth' => THE_BOMB,
            'dateEarliestSingleDay' => THE_BOMB,
            'dateEarliestSingleEra' => THE_BOMB,
            'dateEarliestScalarValue' => THE_BOMB,
            'dateLatestScalarValue' => THE_BOMB,
            'scalarValuesComputed' => THE_BOMB
          }
          @stamp = THE_BOMB
        end
      end
    end
  end
end


# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class DateBomber
        attr_reader :mappable, :stamp
        def initialize
          @mappable = {
            "dateDisplayDate" => THE_BOMB,
            "datePeriod" => THE_BOMB,
            "dateAssociation" => THE_BOMB,
            "dateNote" => THE_BOMB,
            "dateEarliestSingleYear" => THE_BOMB,
            "dateEarliestSingleMonth" => THE_BOMB,
            "dateEarliestSingleDay" => THE_BOMB,
            "dateEarliestSingleEra" => THE_BOMB,
            "dateEarliestSingleCertainty" => THE_BOMB,
            "dateEarliestSingleQualifier" => THE_BOMB,
            "dateEarliestSingleQualifierValue" => THE_BOMB,
            "dateEarliestSingleQualifierUnit" => THE_BOMB,
            "dateLatestYear" => THE_BOMB,
            "dateLatestMonth" => THE_BOMB,
            "dateLatestDay" => THE_BOMB,
            "dateLatestEra" => THE_BOMB,
            "dateLatestCertainty" => THE_BOMB,
            "dateLatestQualifier" => THE_BOMB,
            "dateLatestQualifierValue" => THE_BOMB,
            "dateLatestQualifierUnit" => THE_BOMB,
            "dateEarliestScalarValue" => THE_BOMB,
            "dateLatestScalarValue" => THE_BOMB,
            "scalarValuesComputed" => THE_BOMB
          }
          @stamp = THE_BOMB
        end
      end
    end
  end
end

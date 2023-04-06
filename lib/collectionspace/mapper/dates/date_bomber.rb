# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class DateBomber
        attr_reader :mappable, :stamp
        def initialize
          @mappable = {
            "dateDisplayDate" => CollectionSpace::Mapper.bomb,
            "datePeriod" => CollectionSpace::Mapper.bomb,
            "dateAssociation" => CollectionSpace::Mapper.bomb,
            "dateNote" => CollectionSpace::Mapper.bomb,
            "dateEarliestSingleYear" => CollectionSpace::Mapper.bomb,
            "dateEarliestSingleMonth" => CollectionSpace::Mapper.bomb,
            "dateEarliestSingleDay" => CollectionSpace::Mapper.bomb,
            "dateEarliestSingleEra" => CollectionSpace::Mapper.bomb,
            "dateEarliestSingleCertainty" => CollectionSpace::Mapper.bomb,
            "dateEarliestSingleQualifier" => CollectionSpace::Mapper.bomb,
            "dateEarliestSingleQualifierValue" => CollectionSpace::Mapper.bomb,
            "dateEarliestSingleQualifierUnit" => CollectionSpace::Mapper.bomb,
            "dateLatestYear" => CollectionSpace::Mapper.bomb,
            "dateLatestMonth" => CollectionSpace::Mapper.bomb,
            "dateLatestDay" => CollectionSpace::Mapper.bomb,
            "dateLatestEra" => CollectionSpace::Mapper.bomb,
            "dateLatestCertainty" => CollectionSpace::Mapper.bomb,
            "dateLatestQualifier" => CollectionSpace::Mapper.bomb,
            "dateLatestQualifierValue" => CollectionSpace::Mapper.bomb,
            "dateLatestQualifierUnit" => CollectionSpace::Mapper.bomb,
            "dateEarliestScalarValue" => CollectionSpace::Mapper.bomb,
            "dateLatestScalarValue" => CollectionSpace::Mapper.bomb,
            "scalarValuesComputed" => CollectionSpace::Mapper.bomb
          }
          @stamp = CollectionSpace::Mapper.bomb
        end
      end
    end
  end
end

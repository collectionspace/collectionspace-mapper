# frozen_string_literal: true

require "collectionspace/mapper/version"

require "active_support"
require "active_support/core_ext/object/blank"

require "json"
require "logger"

require "dry-configurable"
require "nokogiri"
require "xxhash"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.inflector.inflect(
  "version" => "VERSION"
)
loader.push_dir("#{__dir__}/mapper", namespace: CollectionSpace::Mapper)
loader.setup
loader.eager_load

module CollectionSpace
  module Mapper
    extend Dry::Configurable
    module_function

    # @return [String] The bomb emoji, used for nuking the contents of fields
    setting :bomb, default: "\u{1F4A3}", reader: true
    # @return [Array<String>]
    setting :structured_date_detailed_fields,
      default: %w[dateDisplayDate datePeriod dateAssociation dateNote
                  dateEarliestSingleYear dateEarliestSingleMonth
                  dateEarliestSingleDay dateEarliestSingleEra
                  dateEarliestSingleCertainty dateEarliestSingleQualifier
                  dateEarliestSingleQualifierValue
                  dateEarliestSingleQualifierUnit dateLatestYear dateLatestMonth
                  dateLatestDay dateLatestEra dateLatestCertainty
                  dateLatestQualifier dateLatestQualifierValue
                  dateLatestQualifierUnit dateEarliestScalarValue
                  dateLatestScalarValue scalarValuesComputed],
      reader: true
  end
end

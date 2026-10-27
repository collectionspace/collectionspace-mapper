# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "collectionspace/client"
require "collectionspace/mapper/version"
require "collectionspace/refcache"
require "dry-configurable"
require "json"
require "logger"
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

    # @param xml [Nokogiri::XML::Document, String]
    def defuse_bomb(xml)
      xml.traverse do |node|
        node.content = "" if node.text == CollectionSpace::Mapper.bomb
      end
      xml
    end
  end
end

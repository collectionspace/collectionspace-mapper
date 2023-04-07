# frozen_string_literal: true

require "collectionspace/mapper/version"
require "collectionspace/client"
require "collectionspace/refcache"

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
    # @return [CollectionSpace::Mapper::RecordMapper, nil]
    setting :recordmapper, default: nil, reader: true
    # @return [CollectionSpace::Client, nil]
    setting :client, default: nil, reader: true
    # @return [CollectionSpace::RefCache, nil] used to store refnames of
    #   looked-up terms
    setting :termcache, default: nil, reader: true
    # @return [CollectionSpace::RefCache, nil] used to store CSIDs of
    #   looked-up entities
    setting :csidcache, default: nil, reader: true
    # @return [Hash] configuration options that change the mapper's behavior
    setting :batchconfigraw, default: {}, reader: true
    # @return [CollectionSpace::Mapper::Config, nil] config object derived
    #   from :batchconfigraw
    setting :batchconfig, default: nil, reader: true




    def setup_data(data, config = Mapper::Config.new)
      if data.is_a?(Hash)
        response = Response.new(data)
      elsif data.is_a?(CollectionSpace::Mapper::Response)
        response = data
      else
        raise CollectionSpace::Mapper::UnprocessableDataError.new(
          "Cannot process a #{data.class}. Need a Hash or Mapper::Response",
          data
        )
      end

      response.merged_data.empty? ? merge_default_values(response,
        config) : response
    end

    def merge_default_values(data, batchconfig)
      defaults = batchconfig.default_values
      return data unless defaults

      mdata = data.orig_data.clone
      defaults.each do |f, val|
        if batchconfig.force_defaults
          mdata[f] = val
        else
          dataval = data.orig_data.fetch(f, nil)
          mdata[f] = val if dataval.nil? || dataval.empty?
        end
      end
      data.merged_data = mdata.compact.transform_keys(&:downcase)
      data
    end
  end
end

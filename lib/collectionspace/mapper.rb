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
    # @return [CollectionSpace::Mapper::DataValidator, nil] class used to
    #   validate data for the batch run
    setting :validator, default: nil, reader: true
    # @return [CollectionSpace::Mapper::Searcher, nil] class used to look up
    #   terms in CS instance for the batch run
    setting :searcher, default: nil, reader: true
    # @return [Constant, nil] class used to prep
    #   data rows for mapping in the batch run
    setting :prepper_class, default: nil, reader: true
    # @return [CollectionSpace::Mapper::Dates::StructuredDateHandler, nil] class
    #   used to handle structured date parsing
    setting :date_handler, default: nil, reader: true
    # @return [CollectionSpace::Mapper::DataHandler, nil] class that sets up
    #   everything for procesing a batch
    setting :data_handler, default: nil, reader: true
    setting :status_checker, default: nil, reader: true
    # @return [Hash] terms used in records which were not found in the CS
    #   instance. We use a Hash instead of an Array so that we don't have to
    #   deduplicate final list, or check that we aren't adding a duplicate
    #   each time we add a value
    setting :new_terms, default: {}, reader: true

    setting :record, reader: true do
      setting :authority_subtype, default: nil, reader: true
      setting :authority_subtypes, default: nil, reader: true
      setting :authority_type, default: nil, reader: true
      setting :document_name, default: nil, reader: true
      setting :identifier_field, default: nil, reader: true
      # @return [CollectionSpace::Mapper::ColumnMappings, nil]
      setting :mappings, default: nil, reader: true
      setting :ns_uri, default: nil, reader: true
      setting :object_name, default: nil, reader: true
      setting :profile_basename, default: nil, reader: true
      setting :recordtype, default: nil, reader: true
      setting :search_field, default: nil, reader: true
      setting :service_name, default: nil, reader: true
      setting :service_path, default: nil, reader: true
      setting :service_type, default: nil, reader: true
      # @return [Constant, nil] mixin module containing behaviors for certain
      #   service types
      setting :service_type_mixin, default: nil, reader: true
      setting :version, default: nil, reader: true
      setting :xml_template, default: nil, reader: true
      setting :xpaths, default: nil, reader: true

      setting :namespaces, default: nil, reader: true,
        constructor: ->(value){ CollectionSpace::Mapper.record.ns_uri.keys }
      setting :common_namespace, default: nil, reader: true,
        constructor: ->(value) do
          CollectionSpace::Mapper.record.namespaces
            .find { |namespace| namespace.end_with?("_common") }
        end
    end

    setting :batch, reader: true do
        setting :check_record_status, default: true, reader: true
        setting :date_format, default: "month day year", reader: true
        setting :default_values, default: {}, reader: true
        setting :delimiter, default: "|", reader: true
        setting :force_defaults, default: false, reader: true
        setting :multiple_recs_found, default: "fail", reader: true
        setting :response_mode, default: "normal", reader: true
        setting :search_if_not_cached, default: true, reader: true
        setting :status_check_method, default: "client", reader: true
        setting :strip_id_values, default: true, reader: true
        setting :subgroup_delimiter, default: "^^", reader: true
        setting :transforms, default: {}, reader: true
        setting :two_digit_year_handling, default: "coerce", reader: true
    end

    def merge_default_values(
      data,
      batchconfig = CollectionSpace::Mapper.batchconfig
    )
      defaults = CollectionSpace::Mapper.batch.default_values
      return data unless defaults

      mdata = data.orig_data.clone
      defaults.each do |f, val|
        if CollectionSpace::Mapper.batch.force_defaults
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

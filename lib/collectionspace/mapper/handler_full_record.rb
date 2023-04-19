# frozen_string_literal: true

require "collectionspace/client"
require "collectionspace/refcache"

module CollectionSpace
  module Mapper
    # given a RecordMapper hash and a data hash, returns CollectionSpace XML
    #   document
    class HandlerFullRecord
      include Dry::Configurable

      setting :batch_mode, default: "full record", reader: true
      # @return [CollectionSpace::Mapper::RecordMapper, nil]
      setting :recordmapper, default: nil, reader: true
      # @return [CollectionSpace::Client, nil]
      setting :client, default: nil, reader: true
      # @return [String] base domain as used in RefName URNs (e.g.
      #   core.collectionspace.org)
      setting :domain, default: nil, reader: true
      # @return [CollectionSpace::RefCache, nil] used to store refnames of
      #   looked-up terms
      setting :termcache, default: nil, reader: true
      # @return [CollectionSpace::RefCache, nil] used to store CSIDs of
      #   looked-up entities
      setting :csidcache, default: nil, reader: true
      # @return [CollectionSpace::Mapper::DataValidator, nil] class used to
      #   validate data for the batch run
      setting :validator, default: nil, reader: true
      # @return [CollectionSpace::Mapper::Searcher, nil] class used to look up
      #   terms in CS instance for the batch run
      setting :searcher, default: nil, reader: true
      setting :data_splitter, default: nil, reader: true
      # @return [Constant, nil] class used to prep
      #   data rows for mapping in the batch run
      setting :prepper_class, default: nil, reader: true
      # @return [CollectionSpace::Mapper::Dates::StructuredDateHandler, nil]
      #   class used to handle structured date parsing
      setting :date_handler, default: nil, reader: true
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
        setting :common_namespace, default: nil, reader: true
        setting :document_name, default: nil, reader: true
        setting :extensions, default: [], reader: true
        setting :identifier_field, default: nil, reader: true
        # @return [CollectionSpace::Mapper::ColumnMappings, nil]
        setting :mappings, default: nil, reader: true
        setting :namespaces, default: nil, reader: true
        setting :ns_uri, default: nil, reader: true
        setting :object_name, default: nil, reader: true
        setting :profile_basename, default: nil, reader: true
        setting :recordtype, default: nil, reader: true
        # @return [Constant, nil] mixin module containing behaviors for certain
        #   record types
        setting :recordtype_mixin, default: nil, reader: true
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

      attr_reader :errors, :warnings

      # @param record_mapper [Hash, String] parseable JSON string or already-
      #   parsed JSON converted to Hash
      # @param client [CollectionSpace::Client]
      # @param cache [CollectionSpace::RefCache] to be used for caching term
      #   refname URNs
      # @param csid_cache [CollectionSpace::RefCache]
      # @param config [Hash, String] parseable JSON string or already-
      #   parsed JSON converted to Hash
      def initialize(record_mapper:, client:, cache:, csid_cache:, config: {})
        pre_initialize

        @errors = []
        @warnings = []
        self.config.client = client
        self.config.domain = client.domain
        self.config.termcache = cache
        self.config.csidcache = csid_cache

        # initializing the RecordMapper causes app config record config
        #   settings to be populated, including :recordtype
        CollectionSpace::Mapper::RecordMapper.new(
          handler: self,
          mapper: record_mapper
        )
        CollectionSpace::Mapper::BatchConfig.new(
          config: config,
          handler: self
        )
        merge_config_transforms
        get_data_validator
        CollectionSpace::Mapper::Searcher.new(self)
        CollectionSpace::Mapper::DataSplitter.new(self)
        self.config.prepper_class = get_prepper_class
        get_date_handler
        self.config.status_checker =
          CollectionSpace::Mapper::Tools::RecordStatusServiceBuilder.call(self)

        post_initialize
      end

      def add_error(error)
        errors << error
        @errors = errors.flatten.compact
      end

      def add_warning(warning)
        warnings << warning
        @warnings = warnings.flatten.compact
      end

      # Prep, then map
      def process(data)
        prepped = data.prep

        case record.recordtype
        when "nonhierarchicalrelationship"
          prepped.map(&:map)
        else
          prepped.map
        end
      end

      # Prep only - This is everything up until the mapping part, including
      #   splitting, stripping, and transforming
      def prep(data)
        response = CollectionSpace::Mapper::Response.new(data, self)
        response.prep
      end

      # Map a prepped response
      def map(response)
        response.map
      end

      # Used by collectionspace-csv-importer preprocessing step
      def check_fields(data)
        data_fields = data.keys.map(&:downcase)
        known = record.mappings.known_columns
        unknown = data_fields - known
        known = data_fields - unknown
        {known_fields: known, unknown_fields: unknown}
      end

      # this is surfaced in public interface because it is used by
      #   collectionspace-csv-importer
      def service_type
        record.service_type
      end

      # Called by CSV Importer preprocessing step
      # @param data [Hash, CollectionSpace::Mapper::Response]
      def validate(data)
        response = if data.is_a?(Hash)
          CollectionSpace::Mapper::Response.new(data, self)
        else
          data
        end
        response.validate
      end

      def to_s
        rectype = record.recordtype
        uri = client.config.base_uri
        id = "#{rectype} #{uri}"
        "<##{self.class}:#{object_id.to_s(8)} #{id}>"
      end
      alias_method :inspect, :to_s

      private

      def pre_initialize
        # Defined in subclasses
      end

      def get_prepper_class
        case record.recordtype
        when "authorityhierarchy"
          CollectionSpace::Mapper::AuthorityHierarchyPrepper
        when "nonhierarchicalrelationship"
          CollectionSpace::Mapper::NonHierarchicalRelationshipPrepper
        when "objecthierarchy"
          CollectionSpace::Mapper::ObjectHierarchyDataPrepper
        else
          CollectionSpace::Mapper::DataPrepper
        end
      end

      def get_date_handler
        CollectionSpace::Mapper::Dates::StructuredDateHandler.new(self)
      end

      def get_data_validator
        CollectionSpace::Mapper::DataValidator.new(self)
      end

      def post_initialize
        # Defined in subclasses
      end

      # you can specify per-data-key transforms in your config.json
      # This method merges the config.json transforms into the
      #   CollectionSpace::Mapper::RecordMapper field mappings for the
      #   appropriate fields
      def merge_config_transforms
        transforms = batch.transforms
        return if transforms.nil? || transforms.empty?

        transforms.transform_keys!(&:downcase)
        transforms.each do |data_column, transforms|
          target_mapping = transform_target(data_column)
          next unless target_mapping

          target_mapping.update_transforms(transforms)
        end
      end

      def transform_target(data_column)
        record.mappings
          .find{ |field_mapping| field_mapping.datacolumn == data_column }
      end
    end
  end
end

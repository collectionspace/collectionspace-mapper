# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # given a RecordMapper hash and a data hash, returns CollectionSpace XML
    #   document
    # @todo Manipulation of recordmapper's xpath_hash belongs on recordmapper
    class DataHandler
      def initialize(record_mapper:, client:, cache:, csid_cache:, config: {})
        CollectionSpace::Mapper.config.client = client
        CollectionSpace::Mapper.config.termcache = cache
        CollectionSpace::Mapper.config.csidcache = csid_cache
        CollectionSpace::Mapper.config.batchconfigraw = config

        CollectionSpace::Mapper::RecordMapper.new(
          mapper: record_mapper
        )
        CollectionSpace::Mapper::Xpaths.new

        # initializing the RecordMapper causes app config record config
        #   settings to be populated, including :recordtype

        CollectionSpace::Mapper.config.batchconfig =
          CollectionSpace::Mapper::Config.new(
            config: CollectionSpace::Mapper.batchconfigraw,
            record_type: CollectionSpace::Mapper.record.recordtype
          )


        CollectionSpace::Mapper.config.validator =
          CollectionSpace::Mapper::DataValidator.new


        CollectionSpace::Mapper::Searcher.new

        CollectionSpace::Mapper.config.prepper_class = get_prepper_class

        CollectionSpace::Mapper.config.date_handler =
          CollectionSpace::Mapper::Dates::StructuredDateHandler.new

        merge_config_transforms

        CollectionSpace::Mapper.config.status_checker =
          CollectionSpace::Mapper::Tools::RecordStatusServiceBuilder.call
        CollectionSpace::Mapper.config.data_handler = self
      end

      # Prep, then map
      def process(data)
        prepped = data.prep

        case CollectionSpace::Mapper.record.recordtype
        when "nonhierarchicalrelationship"
          prepped.responses.map(&:map)
        else
          prepped.response.map
        end
      end

      # Prep only - This is everything up until the mapping part, including
      #   splitting, stripping, and transforming
      def prep(data)
        if data.is_a?(Hash)
          response = CollectionSpace::Mapper::Response.new(data)
        else
          response = data
        end
        response.prep
      end

      # Map a prepped response
      # @todo move to a method on Response
      def map(response)
        result = response.map

        if CollectionSpace::Mapper.batch.response_mode == "normal"
          result.normal
        else
          result
        end
      end

      # Used by collectionspace-csv-importer preprocessing step
      def check_fields(data)
        data_fields = data.keys.map(&:downcase)
        known = CollectionSpace::Mapper.record.mappings.known_columns
        unknown = data_fields - known
        known = data_fields - unknown
        {known_fields: known, unknown_fields: unknown}
      end

      # this is surfaced in public interface because it is used by
      #   collectionspace-csv-importer
      def service_type
        CollectionSpace::Mapper.record.service_type
      end

      # Called by CSV Importer preprocessing step
      # @param data [Hash, CollectionSpace::Mapper::Response]
      def validate(data)
        if data.is_a?(Hash)
          response = CollectionSpace::Mapper::Response.new(data)
        else
          response = data
        end
        response.validate
      end

      def to_s
        rectype = CollectionSpace::Mapper.record.recordtype
        uri = CollectionSpace::Mapper.client.config.base_uri
        id = "#{rectype} #{uri}"
        "<##{self.class}:#{object_id.to_s(8)} #{id}>"
      end
      alias_method :inspect, :to_s

      private

      def get_prepper_class
        case CollectionSpace::Mapper.record.recordtype
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

      # you can specify per-data-key transforms in your config.json
      # This method merges the config.json transforms into the
      #   CollectionSpace::Mapper::RecordMapper field mappings for the
      #   appropriate fields
      def merge_config_transforms
        transforms = CollectionSpace::Mapper.batch.transforms
        return if transforms.nil? || transforms.empty?

        transforms.transform_keys!(&:downcase)
        transforms.each do |data_column, transforms|
          target_mapping = transform_target(data_column)
          next unless target_mapping

          target_mapping.update_transforms(transforms)
        end
      end

      def transform_target(data_column)
        CollectionSpace::Mapper.record.mappings
          .find { |field_mapping| field_mapping.datacolumn == data_column }
      end
    end
  end
end

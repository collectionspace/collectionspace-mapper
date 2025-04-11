# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # Parses JSON RecordMapper given at handler instantiation, and uses it to
    #   set {CollectionSpace::Mapper::DataHandler.record} config options
    #
    # For each record type, there is a JSON RecordMapper containing the config,
    #   field mappings, and template for transforming a hash of data into
    #   CollectionSpace XML
    class RecordMapper
      # @param handler [CollectionSpace::Mapper::DataHandler]
      # @param mapper [String, Hash] parseable JSON string or already-parsed
      #   Hash from JSON
      def initialize(handler:, mapper:)
        @handler = handler
        handler.config.recordmapper = self
        @hash = set_hash(mapper)
        configure_record
      end

      private

      attr_reader :handler, :hash

      def set_hash(mapper)
        return mapper.transform_keys { |key| key.to_sym } if mapper.is_a?(Hash)

        JSON.parse(mapper)
          .transform_keys { |key| key.to_sym }
      end

      def configure_record
        set_config_from_mapper_config_section

        set_extension_configs

        handler.config.record.namespaces = handler.record.ns_uri.keys

        handler.config.record.common_namespace =
          handler.record.namespaces.find do |namespace|
            namespace.end_with?("_common")
          end

        handler.config.record.xml_template =
          CollectionSpace::Mapper::XmlTemplate.call(hash[:docstructure]).doc

        handler.config.record.mappings =
          CollectionSpace::Mapper::ColumnMappings.new(
            mappings: hash[:mappings],
            handler: handler
          )

        CollectionSpace::Mapper::Xpaths.new(handler)
      end

      def set_config_from_mapper_config_section
        hash[:config].each do |setting, value|
          setter = :"#{setting}="
          next unless handler.config.record.respond_to?(setter)

          handler.config.record.send(setter, value)
        end
      end

      def set_extension_configs
        service_type = service_type_extension
        record_type = record_type_extension
        batch_mode = batch_mode_extension
        all = [service_type, record_type, batch_mode].compact.uniq

        handler.config.record.service_type_mixin =
          service_type

        handler.config.record.recordtype_mixin =
          record_type_extension

        handler.config.record.extensions = all
      end

      def record_type_extension
        case handler.record.recordtype
        when "media"
          CollectionSpace::Mapper::Media
        when "objecthierarchy"
          CollectionSpace::Mapper::ObjectHierarchy
        when "authorityhierarchy"
          CollectionSpace::Mapper::AuthorityHierarchy
        when "nonhierarchicalrelationship"
          CollectionSpace::Mapper::NonHierarchicalRelationship
        end
      end

      # The value returned here is used to enable module extension when creating
      #  other classes using RecordMapper
      def service_type_extension
        case handler.record.service_type
        when "authority"
          CollectionSpace::Mapper::Authority
        when "relation"
          CollectionSpace::Mapper::Relationship
        end
      end

      def batch_mode_extension
        case handler.batch_mode
        when "date details"
          CollectionSpace::Mapper::DateDetails
        end
      end
    end
  end
end

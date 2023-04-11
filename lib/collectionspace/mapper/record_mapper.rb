# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # Parses JSON RecordMapper given at app instantiation, and uses it to set
    #   {CollectionSpace::Mapper.record} config options
    #
    # For each record type, there is a JSON RecordMapper containing the config,
    #   field mappings, and template for transforming a hash of data into
    #   CollectionSpace XML
    class RecordMapper
      # @param mapper [String, Hash] parseable JSON string or already-parsed Hash
      #   from JSON
      def initialize(mapper:)
        CollectionSpace::Mapper.config.recordmapper = self
        @hash = set_hash(mapper)
        CollectionSpace::Mapper::RecordMapperConfig.new(hash[:config])
        CollectionSpace::Mapper.config.record.service_type_mixin =
          service_type_extension
        CollectionSpace::Mapper::XmlTemplate.call(hash[:docstructure])
        CollectionSpace::Mapper::ColumnMappings.new(mappings: hash[:mappings])
      end

      private

      attr_reader :hash

      def set_hash(mapper)
        return mapper.transform_keys{ |key| key.to_sym } if mapper.is_a?(Hash)

        JSON.parse(mapper)
          .transform_keys{ |key| key.to_sym }
      end

      # The value returned here is used to enable module extension when creating
      #  other classes using RecordMapper
      def service_type_extension
        case CollectionSpace::Mapper.record.service_type
        when "authority"
          CollectionSpace::Mapper::Authority
        when "relation"
          CollectionSpace::Mapper::Relationship
        when "procedure"
          if CollectionSpace::Mapper.record.recordtype == "media"
            CollectionSpace::Mapper::Media
          end
        else
          nil
        end
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # mapping instructions for an individual data column
    #
    # @todo fix description
    #
    # :reek:InstanceVariableAssumption is spurious; we are setting the instance
    #   variables here by iterating through the mapper hash. Given that the
    #   mapper data is created by the Untangler, I am trusting it will be
    #   consistent and I'm not validating that expected keys are present for
    #   now. This also makes writing tests on the methods here a bit easier.
    class RecordMapperConfig
      attr_reader :profile_basename, :document_name, :service_name,
        :service_path, :service_type, :object_name, :ns_uri, :identifier_field,
        :search_field, :authority_subtypes, :authority_type, :authority_subtype,
        :recordtype

      def initialize(config_hash)
        config_hash.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end

      def common_namespace
        namespaces.select { |namespace| namespace.end_with?("_common") }.first
      end

      def namespaces
        @ns_uri.keys
      end
    end
  end
end

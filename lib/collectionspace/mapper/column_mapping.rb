# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # Mapping instructions for an individual data column
    #
    # :reek:InstanceVariableAssumption is spurious; we are setting the
    #   instance variables here by iterating through the mapper hash. Given that
    #   the mapper data is created by the Untangler, I am trusting it will be
    #   consistent and I'm not validating that expected keys are present for
    #   now. This also makes writing tests on the methods here a bit easier.
    class ColumnMapping
      attr_reader :data_type, :fieldname, :in_repeating_group,
        :is_group, :namespace, :opt_list_values, :repeats, :source_type,
        :transforms, :xpath

      # @param mapping [Hash] for a given CSV column
      # @param authority_companion [Hash]
      def initialize(mapping:, authority_companion: nil)
        @mapping = mapping
        @authority_companion = authority_companion

        mapping.each do |key, value|
          instance_variable_set(:"@#{key}", value)
        end
        symbolize_transforms
      end

      def companion_column
        return unless authority_companion

        authority_companion["datacolumn"]
      end

      def datacolumn = @datacolumn.downcase

      def fullpath = @fullpath ||= [@namespace, @xpath].flatten.join("/")

      # includes both truly required and "required in template"
      def required? = @required.start_with?("y")

      def update_transforms(new_transforms)
        @transforms = @transforms.merge(new_transforms)
      end

      private

      attr_reader :mapping, :authority_companion

      def symbolize_transforms
        return if transforms.blank?

        @transforms.transform_keys!(&:to_sym)
      end
    end
  end
end

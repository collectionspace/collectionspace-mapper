# frozen_string_literal: true

require_relative "tools/symbolizable"

module CollectionSpace
  module Mapper
    # This is the default config, which is modified for object or authority
    #   hierarchy, or non-hierarchichal relationships via module extension
    #
    # Passed in per batch (as Hash parsed from JSON) by
    #   collectionspace-csv-importer
    #
    # :reek:InstanceVariableAssumption - instance variables are set during
    #   initialization
    class Config
      attr_reader :delimiter, :subgroup_delimiter, :response_mode,
        :strip_id_values, :multiple_recs_found, :force_defaults,
        :check_record_status, :status_check_method, :search_if_not_cached,
        :date_format, :two_digit_year_handling, :transforms, :default_values,
        :record_type

      # TODO: move default config in here
      include Tools::Symbolizable

      DEFAULT_CONFIG = {
        check_record_status: true,
        date_format: "month day year",
        delimiter: "|",
        force_defaults: false,
        multiple_recs_found: "fail",
        response_mode: "normal",
        search_if_not_cached: true,
        status_check_method: "client",
        strip_id_values: true,
        subgroup_delimiter: "^^",
        two_digit_year_handling: "coerce",
      }

      VALID_VALUES = {
        response_mode: %w[normal verbose],
        status_check_method: %w[client cache],
        two_digit_year_handling: %w[coerce literal]
      }

      def initialize(opts = {})
        config = opts[:config] || DEFAULT_CONFIG
        @default_values = {}
        @record_type = opts[:record_type]
        extension = record_type_extension
        extend extension if extension

        if config.is_a?(String)
          set_instance_variables(JSON.parse(config))
        elsif config.is_a?(Hash)
          set_instance_variables(config)
        else
          fail CollectionSpace::Mapper::UnhandledConfigFormatError
        end

        special_defaults.each { |col, val| add_default_value(col, val) }
        @default_values.transform_keys!(&:downcase)
        validate
      end

      def hash
        config = to_h
        config = symbolize(config)
        transforms = config[:transforms]
        return config unless transforms

        config[:transforms] = symbolize_transforms(transforms)
        config
      end

      def add_default_value(column, value)
        @default_values ||= {}
        @default_values[column] = value
      end

      private

      def to_h
        hash = {}
        instance_variables.each do |var|
          next if var == :@record_type

          key = var.to_s.delete("@").to_sym
          hash[key] = instance_variable_get(var)
        end
        hash
      end

      def set_instance_variables(hash)
        hash.each { |key, value| instance_variable_set("@#{key}", value) }
      end

      def validate
        begin
          has_required_attributes
        rescue CollectionSpace::Mapper::ConfigKeyMissingError => e
          e.keys.each { |key|
            instance_variable_set("@#{key}", DEFAULT_CONFIG[key])
          }
        end

        validate_setting(:response_mode)
        validate_setting(:status_check_method)
        validate_setting(:two_digit_year_handling)
      end

      # @param setting [Symbol]
      def validate_setting(setting)
        valid = VALID_VALUES[setting]
        setting_variable = "@#{setting}".to_sym
        setting_value = instance_variable_get(setting_variable)
        unless valid.any?(setting_value)
          replacement = DEFAULT_CONFIG[setting]
          self.warn(
            "Config: invalid #{setting} value: #{setting_value}. "\
              "Using default value (#{replacement})"
          )
          instance_variable_set(setting_variable, replacement)
        end
      end

      def has_required_attributes
        required_keys = DEFAULT_CONFIG.keys
        missing_keys = required_keys - hash.keys
        unless missing_keys.empty?
          fail CollectionSpace::Mapper::ConfigKeyMissingError.new(
            missing_keys
          )
        end
      end

      def record_type_extension
        case record_type
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

      def special_defaults
        {}
      end
    end
  end
end

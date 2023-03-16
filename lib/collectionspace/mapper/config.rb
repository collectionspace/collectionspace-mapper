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
        delimiter: "|",
        subgroup_delimiter: "^^",
        response_mode: "normal",
        strip_id_values: true,
        multiple_recs_found: "fail",
        check_record_status: true,
        status_check_method: "client",
        search_if_not_cached: true,
        force_defaults: false,
        date_format: "month day year",
        two_digit_year_handling: "coerce"
      }

      VALID_VALUES = {
        response_mode: %w[normal verbose],
        status_check_method: %w[client cache]
      }

      class ConfigKeyMissingError < StandardError
        attr_reader :keys

        def initialize(message, keys)
          super(message)
          @keys = keys
        end
      end

      class ConfigValueError < StandardError; end

      class UnhandledConfigFormatError < StandardError; end

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
          raise UnhandledConfigFormatError
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
        rescue ConfigKeyMissingError => e
          e.keys.each { |key|
            instance_variable_set("@#{key}", DEFAULT_CONFIG[key])
          }
        end

        validate_setting(:response_mode)
        validate_setting(:status_check_method)
      end

      # @param setting [Symbol]
      def validate_setting(setting)
        valid = VALID_VALUES[setting]
        setting_variable = "@#{setting}".to_sym
        setting_value = instance_variable_get(setting_variable)
        unless valid.any?(setting_value)
          replacement = DEFAULT_CONFIG[setting]
          warn(
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
          raise ConfigKeyMissingError.new("Config missing key",
            missing_keys)
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

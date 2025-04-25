# frozen_string_literal: true

require_relative "tools/symbolizable"

module CollectionSpace
  module Mapper
    # Base batch config, which is modified for object or authority
    #   hierarchy, or non-hierarchichal relationships via module extension
    #
    # Called on initialization of {CollectionSpace::Mapper::DataHandler}, and
    #   sets values in that class' `batch` configuration.
    class BatchConfig
      VALID_VALUES = {
        authority_terms_duplicate_mode: %w[normalized exact],
        batch_mode: ["full record", "date details", "vocabulary terms"],
        check_record_status: ["true", "false", true, false],
        date_format: ["month day year", "day month year"],
        force_defaults: ["true", "false", true, false],
        multiple_recs_found: %w[fail use_first],
        null_value_string_handling: %w[delete empty],
        response_mode: %w[normal verbose],
        search_if_not_cached: ["true", "false", true, false],
        status_check_method: %w[client cache],
        strip_id_values: ["true", "false", true, false],
        two_digit_year_handling: %w[coerce literal]
      }

      # @param handler [CollectionSpace::Mapper::DataHandler]
      # @param config [String, Hash]
      def initialize(handler:, config: {})
        @handler = handler
        @config = parse(config)
        handler.record.extensions.each { |ext| extend ext }

        add_special_defaults
        return if @config.empty?

        @config.transform_keys!(&:to_sym)
        validate
        set_config_settings
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

      attr_reader :config, :handler

      def parse(cfg)
        if cfg.is_a?(String)
          JSON.parse(cfg)
        elsif cfg.is_a?(Hash)
          cfg
        else
          fail CollectionSpace::Mapper::UnhandledConfigFormatError
        end
      end

      # Overridden by some extending modules
      def special_defaults
        {}
      end

      def add_special_defaults
        defaults = config[:default_values] ||= {}
        config[:default_values] = defaults.merge(special_defaults)
          .transform_keys(&:downcase)
      end

      def validate
        VALID_VALUES.keys.each { |setting| validate_setting(setting) }
      end

      # @param setting [Symbol]
      def validate_setting(setting)
        valid = VALID_VALUES[setting]
        return unless config.key?(setting)

        value = config[setting]

        unless valid.any?(value)
          replacement = handler.batch.send(setting)
          message = "BatchConfig: invalid #{setting} value: #{value}.\n"\
            "Value must be one of: #{valid.join(", ")}\n"\
            "Using default value (#{replacement})"
          handler.add_warning(message)
          config.delete(setting)
        end
      end

      def set_config_settings
        config.each do |setting, value|
          set_config(setting, value)
        end
      end

      def set_config(setting, value)
        setter = :"#{setting}="
        handler.config.batch.send(setter, value)
      rescue
        message = "BatchConfig: `#{setting}` is not a valid "\
          "configuration setting"
        handler.add_error(message)
      end
    end
  end
end

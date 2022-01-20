# frozen_string_literal: true

require_relative 'tools/symbolizable'

module CollectionSpace
  module Mapper
    # This is the default config, which is modified for object or authority hierarchy,
    #   or non-hierarchichal relationships via module extension
    # :reek:InstanceVariableAssumption - instance variables are set during initialization
    class Config
      attr_reader :delimiter, :subgroup_delimiter, :response_mode, :strip_id_values, :multiple_recs_found, :force_defaults,
                  :check_record_status, :date_format, :two_digit_year_handling, :transforms, :default_values,
                  :record_type

      # TODO: move default config in here
      include Tools::Symbolizable

      DEFAULT_CONFIG = {delimiter: '|',
                        subgroup_delimiter: '^^',
                        response_mode: 'normal',
                        strip_id_values: true,
                        multiple_recs_found: 'fail',
                        check_record_status: true,
                        force_defaults: false,
                        date_format: 'month day year',
                        two_digit_year_handling: 'coerce'}

      class ConfigKeyMissingError < StandardError
        attr_reader :keys

        def initialize(message, keys)
          super(message)
          @keys = keys
        end
      end

      class ConfigResponseModeError < StandardError; end

      class UnhandledConfigFormatError < StandardError; end

      def initialize(opts = {})
        config = opts[:config] || DEFAULT_CONFIG
        self.record_type = opts[:record_type]

        @default_values = {}

        if config.is_a?(String)
          set_instance_variables(JSON.parse(config))
        elsif config.is_a?(Hash)
          set_instance_variables(config)
        else
          raise UnhandledConfigFormatError
        end

        special_defaults.each{ |col, val| add_default_value(col, val) }
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

      def record_type=(mawdule)
        return unless mawdule

        extend(mawdule)
      end

      def to_h
        hash = {}
        instance_variables.each do |var|
          next if var == :@record_type

          key = var.to_s.delete('@').to_sym
          hash[key] = instance_variable_get(var)
        end
        hash
      end

      def set_instance_variables(hash)
        hash.each{ |key, value| instance_variable_set("@#{key}", value) }
      end

      def validate
        begin
          has_required_attributes
        rescue ConfigKeyMissingError => e
          e.keys.each{ |key| instance_variable_set("@#{key}", DEFAULT_CONFIG[key]) }
        end

        begin
          valid_response_mode
        rescue ConfigResponseModeError => e
          replacement_value = DEFAULT_CONFIG[:response_mode]
          @response_mode = replacement_value
        end
      end

      def valid_response_mode
        valid = %w[normal verbose]
        unless valid.any?(@response_mode)
          raise ConfigResponseModeError, "Invalid response_mode value in config: #{@response_mode}"
        end
      end

      def has_required_attributes
        required_keys = DEFAULT_CONFIG.keys
        remaining_keys = required_keys - hash.keys
        raise ConfigKeyMissingError.new('Config missing key', remaining_keys) unless remaining_keys.empty?
      end

      def special_defaults
        {}
      end
    end
  end
end

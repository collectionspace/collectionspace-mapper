# frozen_string_literal: true

require_relative 'tools/symbolizable'

module CollectionSpace
  module Mapper

    # This is the default config, which is modified for object or authority hierarchy,
    #   or non-hierarchichal relationships via module extension
    # :reek:InstanceVariableAssumption - instance variables are set during initialization
    class Config
      attr_reader :delimiter, :subgroup_delimiter, :response_mode, :force_defaults, :check_record_status,
        :check_terms, :date_format, :two_digit_year_handling, :ambiguous_month_day, :transforms, :default_values,
        :record_type
      # todo: move default config in here
      include Tools::Symbolizable

      DEFAULT_CONFIG = { delimiter: '|',
                        subgroup_delimiter: '^^',
                        response_mode: 'normal',
                        check_terms: true,
                        check_record_status: true,
                        force_defaults: false,
                        two_digit_year_handling: :coerce
                       }

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
        self.record_type = opts[:record_type]
        
        passed_config = opts[:config] || {}
        
        if passed_config.is_a?(String)
          hash_config = JSON.parse(passed_config).transform_keys!(&:to_sym)
        elsif passed_config.is_a?(Hash)
          hash_config = passed_config
        elsif passed_config.is_a?(CS::Mapper::Config)
          hash_config = passed_config.hash
        else
          raise UnhandledConfigFormatError
        end

        merged_config = default_config.merge(hash_config)

        set_instance_variables(merged_config)

        @default_values = merged_config[:default_values] || {}
        special_defaults.each{ |col, val| add_default_value(col, val) }
        @default_values.transform_keys!(&:downcase)
        validate
      end

      def date_config
        date_options = {}
        Emendate::Options.new.options.keys.each do |optname|
          date_options[optname] = send(optname) if self.respond_to?(optname)
        end
        date_options
      end
      
      def hash
        config = self.to_h
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

      def default_config
        DEFAULT_CONFIG.merge(Emendate::Options.new.options)
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
        rescue ConfigKeyMissingError => err
          err.keys.each{ |key| instance_variable_set("@#{key}", DEFAULT_CONFIG[key]) }
        end

        begin
          valid_response_mode
        rescue ConfigResponseModeError => err
          replacement_value = DEFAULT_CONFIG[:response_mode]
          @response_mode = replacement_value
        end
      end

      def valid_response_mode
        valid = %w[normal verbose]
        unless valid.any?(@response_mode)
          raise ConfigResponseModeError.new("Invalid response_mode value in config: #{@response_mode}")
        end
      end
      
      def has_required_attributes
        required_keys = DEFAULT_CONFIG.keys
        remaining_keys = required_keys - hash.keys
        unless remaining_keys.empty?
          raise ConfigKeyMissingError.new('Config missing key', remaining_keys)
        end
      end

      def special_defaults
        {}
      end
    end
  end
end


# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataQualityChecker
      attr_reader :mapping, :data, :warnings, :terms

      def initialize(mapping, data)
        @mapping = mapping
        @column = mapping.datacolumn
        @field = mapping.fieldname
        @data = data
        @warnings = []
        @terms = []
        @source_type = @mapping.source_type

        case @source_type
        when 'authority'
          validate_refnames if @column['refname']
        when 'vocabulary'
          validate_refnames if @column['refname']
        when 'optionlist'
          check_opt_list_vals
        end
      end

      private

      def validate_refnames
        if @data.first.is_a?(String)
          @data.each{ |val| validate_refname(val) unless val.blank? || val == '%NULLVALUE%' }
        else
          @data.each{ |arr| arr.each{ |val| validate_refname(val) unless val.blank? || val == '%NULLVALUE%' } }
        end
      end

      def validate_refname(val)
        type_segment = {
          'authority' => ':\w+authorit(ies|y):',
          'vocabulary' => ':vocabularies:'
        }
        pattern = Regexp.new("^urn:cspace:.+#{type_segment[@source_type]}name\(.+\):item:name(.+)'.+'$")
        return if val.match?(pattern)

        @warnings << {
          category: :malformed_refname_value,
          field: @column,
          type: @source_type,
          subtype: nil,
          value: val,
          message: "Malformed refname value in #{@column} column. Malformed value: #{val}."
        }
      end

      def check_opt_list_vals
        @opts = @mapping.opt_list_values
        if @data.first.is_a?(String)
          @data.each{ |val| check_opt_list_val(val) }
        else
          @data.each{ |arr| arr.each{ |val| check_opt_list_val(val) } }
        end
      end

      def check_opt_list_val(val)
        return if val.blank?
        return if val == '%NULLVALUE%'
        return if @opts.include?(val)

        @warnings << {
          category: :unknown_option_list_value,
          field: @column,
          type: 'option list value',
          subtype: '',
          value: val,
          message: "Unknown value `#{val}` in option list `#{@column}` column"
        }
      end
    end
  end
end

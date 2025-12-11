# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataQualityChecker
      # Data types that we need to validate because CollectionSpace doesn't
      TO_VALIDATE = %w[boolean integer float]

      class << self
        def checkable?(mapping)
          true if mapping.source_type == "optionlist" ||
            mapping.datacolumn["refname"] ||
            TO_VALIDATE.include?(mapping.data_type)
        end
      end

      attr_reader :mapping, :data, :warnings, :terms

      def initialize(mapping, data, response)
        @mapping = mapping
        @data = data
        @response = response

        @column = mapping.datacolumn
        @field = mapping.fieldname

        if %w[authority vocabulary].include?(mapping.source_type) &&
            column.match?("refname")
          validate_all_refnames if @column["refname"]
        elsif mapping.source_type == "optionlist"
          check_all_opt_list_vals
        elsif TO_VALIDATE.include?(mapping.data_type)
          validate_data_type
        end
      end

      private

      attr_reader :response, :column

      def validate_data_type
        vals = data.first.is_a?(String) ? data : data.flatten
        result = vals.reject do |v|
          v.blank? ||
            v == "%NULLVALUE%" ||
            v == CollectionSpace::Mapper.bomb ||
            valid_data_type?(v)
        end
        add_data_type_error(result) unless result.empty?
      end

      def valid_data_type?(v) = send(:"valid_#{mapping.data_type}?", v)

      def valid_boolean?(v) = v.match?(/^(?:true|false)$/)

      def valid_float?(v) = v.match?(/^\d+(?:\.\d+)?$/)

      def valid_integer?(v) = v.match?(/^\d+$/)

      # @param [Array<String>]
      def add_data_type_error(vals)
        response.add_error({
          category: :invalid_value_for_data_type,
          message: "The #{column} column's data type is "\
            "#{mapping.data_type}. The following values are not valid "\
            "#{mapping.data_type}s: #{vals.join("|")}"
        })
      end

      def validate_all_refnames
        if data.first.is_a?(String)
          validate_refnames(data)
        else
          data.each { |refnames| validate_refnames(refnames) }
        end
      end

      def validate_refnames(refnames)
        refnames.each do |val|
          validate_refname(val) unless val.blank? || val == "%NULLVALUE%"
        end
      end

      # @todo Use client refname parser to validate instead of a regexp
      def validate_refname(val)
        CollectionSpace::RefName.parse(val)
      rescue
        response.add_error({
          category: :malformed_refname_value,
          field: column,
          type: mapping.source_type,
          subtype: nil,
          value: val,
          message: "Malformed refname value in #{column} column. Malformed "\
            "value: #{val}."
        })
      end

      def check_all_opt_list_vals
        opts = mapping.opt_list_values
        if data.first.is_a?(String)
          check_opt_list_vals(data, opts)
        else
          data.each { |vals| check_opt_list_vals(vals, opts) }
        end
      end

      def check_opt_list_vals(data, opts)
        unknown = data.reject do |val|
          val.blank? ||
            val == "%NULLVALUE%" ||
            opts.any?(val)
        end
        return if unknown.empty?

        unknown.each do |val|
          response.add_warning(
            unknown_option_list_warning(val)
          )
        end
      end

      def unknown_option_list_warning(val)
        {
          category: :unknown_option_list_value,
          field: column,
          type: "option list value",
          subtype: "",
          value: val,
          message: "Unknown value `#{val}` in option list `#{column}` column"
        }
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataQualityChecker
      class << self
        def checkable?(mapping)
          true if mapping.source_type == "optionlist" ||
            mapping.datacolumn["refname"]
        end
      end

      attr_reader :mapping, :data, :warnings, :terms

      def initialize(mapping, data, response)
        @mapping = mapping
        @data = data
        @response = response

        @column = mapping.datacolumn
        @field = mapping.fieldname

        case mapping.source_type
        when "authority"
          validate_all_refnames if @column["refname"]
        when "vocabulary"
          validate_all_refnames if @column["refname"]
        when "optionlist"
          check_all_opt_list_vals
        end
      end

      private

      attr_reader :response, :column

      def validate_all_refnames
        if data.first.is_a?(String)
          validate_refnames(data)
        else
          data.each { |refnames| validate_refnames(refnames) }
        end
      end

      def validate_refnames(refnames)
        refnames.each { |val|
          validate_refname(val) unless val.blank? || val == "%NULLVALUE%"
        }
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

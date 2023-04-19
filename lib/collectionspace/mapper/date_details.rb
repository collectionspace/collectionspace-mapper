# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module DateDetails
      # Methods used in ColumnMappings
      def special_mappings
        base = [
          {
            fieldname: "date_field_group",
            namespace: handler.record.common_namespace,
            data_type: "string",
            xpath: [],
            required: "y",
            repeats: "n",
            in_repeating_group: "n/a",
            datacolumn: "date_field_group",
            transforms: {}
          },
          {
            fieldname: "scalarValuesComputed",
            namespace: handler.record.common_namespace,
            data_type: "string",
            xpath: [],
            required: "y",
            repeats: "n",
            in_repeating_group: "n/a",
            datacolumn: "scalarValuesComputed",
            transforms: {special: ["boolean"]}
          }
        ]
        [base, vocab_mappings, optionlist_mappings].flatten
      end

      def vocab_mappings
        {
          "dateLatestQualifierUnit"=>"datequalifier",
          "dateLatestEra"=>"dateera",
          "dateLatestCertainty"=>"datecertainty",
          "dateEarliestSingleQualifierUnit"=>"datequalifier",
          "dateEarliestSingleEra"=>"dateera",
          "dateEarliestSingleCertainty"=>"datecertainty"
        }.map do |fieldname, vocab|
          {
            fieldname: fieldname,
            namespace: handler.record.common_namespace,
            data_type: "string",
            xpath: [],
            required: "n",
            repeats: "n",
            in_repeating_group: "n/a",
            datacolumn: fieldname,
            source_type: "vocabulary",
            source_name: vocab,
            transforms: {vocabulary: vocab}
          }
        end
      end

      def optionlist_mappings
        {
          "dateLatestQualifier"=>"dateQualifiers",
          "dateEarliestSingleQualifier"=>"dateQualifiers"
        }.map do |fieldname, vocab|
          {
            fieldname: fieldname,
            namespace: handler.record.common_namespace,
            data_type: "string",
            xpath: [],
            required: "n",
            repeats: "n",
            in_repeating_group: "n/a",
            datacolumn: fieldname,
            source_type: "optionlist",
            source_name: vocab,
            transforms: {},
            opt_list_values: ["", "+", "+/-", "-"]
          }
        end
      end

      # methods used in DataValidator
      def special_checks(response)
        ensure_target_field_exists(response)
        ensure_scalar_values_computed_value(response)
      end

      def ensure_target_field_exists(response)
        val = response.merged_data["date_field_group"]
        return if handler.record.mappings.map(&:fieldname).any?(val)

        response.add_error(
          "date_field_group value `#{val}` is not a known structured date "\
            "field group in a #{handler.record.recordtype} record. You must "\
            "enter a field that appears as a column header in the CSV "\
            "template for this record type."
        )
      end

      def ensure_scalar_values_computed_value(response)
        exp = CollectionSpace::Mapper::ValueTransformer::BOOLEAN_LOOKUP.keys
        vals = response.merged_data["scalarvaluescomputed"]
          .split(handler.batch.delimiter)
          .reject{ |val| exp.any?(val) }
        return if vals.empty?

        response.add_error(
          "scalarValuesComputed values `#{vals.join(", ")}` cannot be "\
            "converted to true or false, and thus cannot be ingested"
        )
      end

      # methods used in Xpaths
      def keep_fields(data)
        [
          handler.record.identifier_field,
          data["date_field_group"]
        ].map(&:downcase)
      end
    end
  end
end

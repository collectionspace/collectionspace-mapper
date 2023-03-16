# frozen_string_literal: true

require_relative "transformer"

module CollectionSpace
  module Mapper
    # transforms a variety of binary values into Boolean string values for CS
    class BooleanTransformer < Transformer
      def transform(value)
        return "false" if value.blank?

        case value.downcase
        when "true"
          "true"
        when "false"
          "false"
        when ""
          "false"
        when "yes"
          "true"
        when "no"
          "false"
        when "y"
          "true"
        when "n"
          "false"
        when "t"
          "true"
        when "f"
          "false"
        else
          @warnings << {
            category: :boolean_value_transform,
            field: nil,
            type: nil,
            subtype: nil,
            value: value,
            message: "#{value} cannot be converted to boolean. Defaulting to "\
              "false"
          }
          "false"
        end
      end
    end
  end
end

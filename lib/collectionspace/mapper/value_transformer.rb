# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # Performs specified transforms on a given string and returns transformed
    #   result
    #
    # @note @value is mutated as transforms are applied
    class ValueTransformer
      include TermSearchable # for :obj_csid method only

      class << self
        # @param value [String]
        # @param mapping [CollectionSpace::Mapper::ColumnMapping]
        # @param handler [CollectionSpace::Mapper::DataHandler]
        # @param response [CollectionSpace::Mapper::Response]
        def call(value:, mapping:, handler:, response:)
          new(
            value: value,
            mapping: mapping,
            handler: handler,
            response: response
          ).call
        end
      end

      BOOLEAN_LOOKUP = {
        "true" => "true",
        "false" => "false",
        "" => "false",
        "yes" => "true",
        "no" => "false",
        "y" => "true",
        "n" => "false",
        "t" => "true",
        "f" => "false",
        "%nullvalue%" => "false",
        "%NULLVALUE%" => "false"
      }

      # @param value [String]
      # @param mapping [CollectionSpace::Mapper::ColumnMapping]
      # @param handler [CollectionSpace::Mapper::DataHandler]
      # @param response [CollectionSpace::Mapper::Response]
      def initialize(value:, mapping:, handler:, response:)
        @value = value.dup
        @transforms = mapping.transforms
        @column = mapping.datacolumn
        @handler = handler
        @response = response

        # The following are used by TermSearchable
        @cache = handler.termcache
        @client = handler.client
      end

      def call
        process_replacements if transforms.key?(:replacements)
        process_special if transforms.key?(:special)
        value
      end

      private

      attr_reader :value, :transforms, :column, :handler, :response

      def process_replacements
        return value if value.nil? || value.empty?

        transforms[:replacements].each do |rule|
          find = rule[:find]
          replace = rule[:replace]

          case rule[:type]
          when :plain
            @value = value.gsub(find, replace)
          when :regexp
            @value = value.gsub(Regexp.new(find), replace)
          end
        end
      end

      def process_special
        special = transforms[:special]
        @value = process_boolean if special.include?("boolean")

        unless value.nil? || value.empty?
          @value = value.downcase if special.include?("downcase_value")
          @value = process_behrensmeyer if special.include?(
            "behrensmeyer_translate"
          )
          @value = obj_csid(value, "collectionobjects") if special.include?(
            "obj_num_to_csid"
          )
        end
      end

      def process_boolean
        return "false" if value.blank?

        lookupval = BOOLEAN_LOOKUP[value.downcase]
        return lookupval if lookupval

        response.add_warning({
          category: :boolean_value_transform,
          field: column,
          type: nil,
          subtype: nil,
          value: value,
          message: "#{value} cannot be converted to boolean. Defaulting to "\
            "false"
        })
        "false"
      end

      def process_behrensmeyer
        lookup = {
          "0" => "0 - no cracking or flaking on bone surface",
          "1" => "1 - longitudinal and/or mosaic cracking present on surface",
          "2" => "2 - longitudinal cracks, exfoliation on surface",
          "3" => "3 - fibrous texture, extensive exfoliation",
          "4" =>
            "4 - coarsely fibrous texture, splinters of bone loose on the "\
            "surface, open cracks",
          "5" => "5 - bone crumbling in situ, large splinters"
        }

        lookup.key?(value) ? lookup[value] : value
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class ValueTransformer
      include TermSearchable
      attr_reader :orig, :result, :warnings, :errors

      # @todo appconfig remove prepper arg
      def initialize(value, transforms, prepper)
        @value = value
        @orig = @value.clone
        @warnings = []
        @errors = []

        @transforms = transforms
        @cache = CollectionSpace::Mapper.termcache
        @client = CollectionSpace::Mapper.client
        @missing = {}
        process_replacements if @transforms.key?(:replacements)
        process_special if @transforms.key?(:special)
        @result = @value
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
        "f" => "false"
      }

      def process_replacements
        return if @value.empty?

        @transforms[:replacements].each do |rule|
          find = rule[:find]
          replace = rule[:replace]

          case rule[:type]
          when :plain
            @value = @value.gsub(find, replace)
          when :regexp
            @value = @value.gsub(Regexp.new(find), replace)
          end
        end
      end

      def process_special
        special = @transforms[:special]
        process_boolean if special.include?("boolean")
        unless @value.empty?
          @value = @value.downcase if special.include?("downcase_value")
          process_behrensmeyer if special.include?("behrensmeyer_translate")
          obj_num_to_csid if special.include?("obj_num_to_csid")
        end
      end

      def process_boolean
        if @value.blank?
          @value = "false"
          return
        end

        chkval = @value.downcase
        if BOOLEAN_LOOKUP.key?(chkval)
          @value = BOOLEAN_LOOKUP[chkval]
          return
        end

        @value = "false"
        msg = "#{@value} cannot be converted to boolean. Defaulting to false"
        @warnings << {
          category: :boolean_value_transform,
          field: nil,
          type: nil,
          subtype: nil,
          value: @value,
          message: msg
        }
      end

      def obj_num_to_csid
        @value = obj_csid(@value, "collectionobjects")
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
        @value = lookup.fetch(@value, @value)
      end
    end
  end
end

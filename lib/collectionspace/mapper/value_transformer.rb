# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class ValueTransformer
      include TermSearchable
      attr_reader :orig, :result, :warnings, :errors
      def initialize(value, transforms, prepper)
        @value = value
        @orig = @value.clone
        @warnings = []
        @errors = []

        @transforms = transforms
        @cache = prepper.cache
        @client = prepper.client
        @missing = {}
        process_replacements if @transforms.key?(:replacements)
        process_special if @transforms.key?(:special)
        @result = @value
      end

      def process_replacements
        return if @value.empty?

        @transforms[:replacements].each do |r|
          case r[:type]
          when :plain
            @value = @value.gsub(r[:find], r[:replace])
          when :regexp
            @value = @value.gsub(Regexp.new(r[:find]), r[:replace])
          end
        end
      end

      def process_special
        special = @transforms[:special]
        process_boolean if special.include?('boolean')
        unless @value.empty?
          @value = @value.downcase if special.include?('downcase_value')
          process_behrensmeyer if special.include?('behrensmeyer_translate')
          obj_num_to_csid if special.include?('obj_num_to_csid')
        end
      end

      def process_boolean
        if @value.blank?
          @value = 'false'
        else
          case @value.downcase
          when 'true'
            @value = 'true'
          when 'false'
            @value = 'false'
          when ''
            @value = 'false'
          when 'yes'
            @value = 'true'
          when 'no'
            @value = 'false'
          when 'y'
            @value = 'true'
          when 'n'
            @value = 'false'
          when 't'
            @value = 'true'
          when 'f'
            @value = 'false'
          else
            @value = 'false'
            @warnings << {
              category: :boolean_value_transform,
              field: nil,
              type: nil,
              subtype: nil,
              value: @value,
              message: "#{@value} cannot be converted to boolean. Defaulting to false"
            }
          end
        end
      end

      def obj_num_to_csid
        @value = obj_csid(@value, 'collectionobjects')
      end

      def process_behrensmeyer
        lookup = {
          '0' => '0 - no cracking or flaking on bone surface',
          '1' => '1 - longitudinal and/or mosaic cracking present on surface',
          '2' => '2 - longitudinal cracks, exfoliation on surface',
          '3' => '3 - fibrous texture, extensive exfoliation',
          '4' => '4 - coarsely fibrous texture, splinters of bone loose on the surface, open cracks',
          '5' => '5 - bone crumbling in situ, large splinters'
        }
        @value = lookup.fetch(@value, @value)
      end
    end
  end
end


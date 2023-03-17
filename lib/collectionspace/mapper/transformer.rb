# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # parent class of the data value Transformer class hierarchy
    class Transformer
      attr_reader :precedence, :warnings

      class << self
        def create(type:, recmapper:, transform: {})
          case type.to_sym
          when :authority
            AuthorityTransformer.new(transform: transform, recmapper: recmapper)
          when :vocabulary
            VocabularyTransformer.new(transform: transform, recmapper: recmapper)
          when :special
            transform.map { |xformname| special_transformers(xformname) }
          when :replacements
            FindReplaceTransformer.new(transform: transform)
          end
        end

        def special_transformers(xformname)
          case xformname
          when "boolean"
            BooleanTransformer.new
          when "behrensmeyer_translate"
            BehrensmeyerTransformer.new
          when "downcase_value"
            DowncaseTransformer.new
          end
        end
      end

      def initialize(_opts = {})
        @precedence = lookup_precedence
        @warnings = []
      end

      def transform(value)
      end

      def <=>(other)
        @precedence <=> other.precedence
      end

      private

      def lookup_precedence
        [
          CollectionSpace::Mapper::FindReplaceTransformer,
          CollectionSpace::Mapper::DowncaseTransformer,
          CollectionSpace::Mapper::BooleanTransformer,
          CollectionSpace::Mapper::DateStampTransformer,
          CollectionSpace::Mapper::StructuredDateTransformer,
          CollectionSpace::Mapper::BehrensmeyerTransformer,
          CollectionSpace::Mapper::VocabularyTransformer,
          CollectionSpace::Mapper::AuthorityTransformer,
          CollectionSpace::Mapper::Transformer
        ].find_index(self.class)
      end
    end
  end
end

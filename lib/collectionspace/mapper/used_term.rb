# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # Data object to represent a term used in a field in a data row
    class UsedTerm
      include Comparable
      extend Forwardable

      attr_reader :term, :category, :field, :key

      def_delegators :@refname, :type, :subtype, :identifier, :display_name,
        :urn

      # @param term [String] original value used in incoming data
      # @param category [:authority, :vocabulary]
      # @param field [String] where term was used
      # @param found [Boolean]
      # @param refname [CollectionSpace::Mapper::Tools::RefName,
      #   CollectionSpace::Mapper::UnknownTerm]
      def initialize(term:, category:, field:, found:, refname:)
        @term = term
        @category = category
        @field = field
        @found = found
        @refname = refname
        @key = refname.key
      end

      def <=>(other)
        key <=> other.key
      end

      def found? = found

      def missing? = !found

      def to_h
        {
          category: category,
          field: field,
          refname: refname,
          found: found?
        }
      end

      private

      attr_reader :found, :refname
    end
  end
end

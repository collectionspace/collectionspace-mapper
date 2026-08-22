# frozen_string_literal: true

require "forwardable"

module CollectionSpace
  module Mapper
    # Aggregate class to work with all of a RecordMapper's ColumnMapping objects
    #   in an Array-ish fashion
    class ColumnMappings
      include Enumerable
      extend Forwardable

      attr_reader :handler

      def_delegators :@all, :each, :reject!

      # @param mappings [Array<Hash>] from record mapper JSON file
      # @param handler [CollectionSpace::Mapper::DataHandler]
      # @param ingestformat [:csvimporter, :datatoolkit]
      def initialize(mappings:, handler:, ingestformat: :csvimporter)
        @mappings = mappings
        @handler = handler
        @ingestformat = ingestformat
        @transforms = handler.batch.transforms

        @all = []
        @lkup = {}
        handler.record.extensions.each { |ext| extend ext }
        mappings.each { |mapping| add_mapping(mapping) }
      end

      def <<(mapping) = add_mapping(mapping)

      def known_columns = all.map(&:datacolumn)

      def lookup(columnname) = lkup[columnname.downcase]

      # Columns that are required for initial processing of CSV data
      #
      # For non-hierarchical relationships and authority hierarchy
      #   relationships, includes some columns that do not ultimately get
      #   mapped to XML
      def required_columns = all.select(&:required?)

      def add_mapping(mapping)
        mapobj = build_mapping(mapping)
        @all << mapobj
        @lkup[mapobj.datacolumn] = mapobj
      end

      private

      attr_reader :mappings, :ingestformat, :transforms, :all, :lkup

      def build_mapping(mapping)
        if ingestformat == :csvimporter ||
            (ingestformat == :datatoolkit && nonauth?(mapping))
          return CollectionSpace::Mapper::ColumnMapping.new(mapping: mapping)
        end

        build_datatoolkit_authority_mapping(mapping)
      end

      def build_datatoolkit_authority_mapping(mapping)
        CollectionSpace::Mapper::ColumnMapping.new(
          mapping: mapping,
          authority_companion: find_companion(mapping)
        )
      end

      def find_companion(mapping)
        mappings.find do |m|
          m["fieldname"] == mapping["fieldname"] &&
            m["source_type"] == "authority vocabulary indication"
        end
      end

      def auth?(mapping) = mapping["source_type"] == "authority"

      def nonauth?(mapping) = !auth?(mapping)
    end
  end
end

# frozen_string_literal: true

require "forwardable"

module CollectionSpace
  module Mapper
    # Aggregate class to work with all of a RecordMapper's ColumnMapping objects
    #   in an Array-ish fashion
    class ColumnMappings
      include Enumerable
      extend Forwardable

      def_delegators :@all, :each, :reject!

      # @param mappings [Array<Hash>] from record mapper JSON file
      # @param hander [CollectionSpace::Mapper::DataHandler]
      def initialize(mappings:, handler:)
        @handler = handler
        handler.record.extensions.each{ |ext| extend ext }

        @all = []
        @lkup = {}
        mappings.each { |mapping| add_mapping(mapping) }

        special_mappings.each { |mapping| add_mapping(mapping) }
      end

      def <<(mapping)
        add_mapping(mapping)
      end

      def known_columns
        all.map(&:datacolumn)
      end

      def lookup(columnname)
        lkup[columnname.downcase]
      end

      # Columns that are required for initial processing of CSV data
      #
      # For non-hierarchical relationships and authority hierarchy
      #   relationships, includes some columns that do not ultimately get
      #   mapped to XML
      def required_columns
        all.select(&:required?)
      end

      private

      attr_reader :handler, :all, :lkup

      def add_mapping(mapping)
        mapobj = CollectionSpace::Mapper::ColumnMapping.new(
          mapping: mapping
        )
        all << mapobj
        lkup[mapobj.datacolumn] = mapobj
      end

      def special_mappings
        []
      end
    end
  end
end

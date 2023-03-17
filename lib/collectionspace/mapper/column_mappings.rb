# frozen_string_literal: true

require "forwardable"

module CollectionSpace
  module Mapper
    # Aggregate class to work with all of a RecordMapper's ColumnMapping objects
    #   in an Array-ish fashion
    class ColumnMappings
      include Enumerable
      extend Forwardable

      attr_reader :config

      def_delegators :@all, :each, :reject!

      def initialize(opts = {})
        @mapper = opts[:mapper]
        @config = mapper.config
        extension = mapper.service_type_extension
        extend extension if extension

        @all = []
        @lkup = {}
        opts[:mappings].each { |mapping_hash| add_mapping(mapping_hash) }
        special_mappings.each { |mapping| add_mapping(mapping) }
      end

      def <<(mapping_hash)
        add_mapping(mapping_hash)
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

      attr_reader :mapper, :all, :lkup

      def add_mapping(mapping_hash)
        mapobj = CollectionSpace::Mapper::ColumnMapping.new(
          mapping_hash,
          mapper
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

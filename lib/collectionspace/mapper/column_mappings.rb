# frozen_string_literal: true

require 'forwardable'

module CollectionSpace
  module Mapper
    # aggregate class to work with all of a RecordMapper's ColumnMapping objects in an
    #   Array-ish fashion
    class ColumnMappings
      extend Forwardable

      attr_reader :config

      def_delegators :@all, :each, :length, :map, :reject!, :select

      def initialize(opts = {})
        @mapper = opts[:mapper]
        @config = @mapper.config
        self.service_type = @mapper.service_type
        @all = []
        @lookup = {}
        opts[:mappings].each{ |mapping_hash| add_mapping(mapping_hash) }
        special_mappings.each{ |mapping| add_mapping(mapping) }
      end

      def <<(mapping_hash)
        add_mapping(mapping_hash)
      end

      def known_columns
        @all.map(&:datacolumn)
      end

      def lookup(columnname)
        @lookup[columnname.downcase]
      end

      # columns that are required for initial processing of CSV data
      # For non-hierarchical relationships and authority hierarchy relationships, includes some columns
      #   that do not ultimately get mapped to XML
      def required_columns
        @all.select(&:required?)
      end

      private

      def service_type=(mawdule)
        return unless mawdule

        extend(mawdule)
      end

      def add_mapping(mapping_hash)
        mapobj = CS::Mapper::ColumnMapping.new(mapping_hash, @mapper)
        @all << mapobj
        @lookup[mapobj.datacolumn] = mapobj
      end

      def special_mappings
        []
      end
    end
  end
end

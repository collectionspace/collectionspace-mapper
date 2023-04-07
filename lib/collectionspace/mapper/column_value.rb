# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # Represents a data field from a row of a CSV.
    class ColumnValue
      # @param column [String]
      # @param value [String]
      # @param recmapper [CollectionSpace::Mapper::RecordMapper]
      # @param mapping [CollectionSpace::Mapper::ColumnMapping]
      def initialize(
        column:,
        value:,
        recmapper: CollectionSpace::Mapper.recordmapper,
        mapping:
      )
        @column = column.downcase
        @value = value
        @recmapper = recmapper
        @mapping = mapping
      end

      # @param column [String]
      # @param value [String]
      # @param recmapper [CollectionSpace::Mapper::RecordMapper]
      # @param mapping [CollectionSpace::Mapper::ColumnMapping]
      def self.create(
        column:,
        value:,
        recmapper: CollectionSpace::Mapper.recordmapper,
        mapping:
      )
        case mapping.xpath.length
        when 0
          ColumnValue.new(
            column: column,
            value: value,
            recmapper: recmapper,
            mapping: mapping
          )
        when 1
          MultivalColumnValue.new(
            column: column,
            value: value,
            recmapper: recmapper,
            mapping: mapping
          )
        when 2
          GroupColumnValue.new(
            column: column,
            value: value,
            recmapper: recmapper,
            mapping: mapping
          )
        when 3
          # bonsai conservation fertilizerToBeUsed is the only field like this
          GroupMultivalColumnValue.new(
            column: column,
            value: value,
            recmapper: recmapper,
            mapping: mapping
          )
        when 4
          SubgroupColumnValue.new(
            column: column,
            value: value,
            recmapper: recmapper,
            mapping: mapping
          )
        end
      end

      def split
        [@value.strip]
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # @todo Finish implementing
    #
    # Represents a data field from a row of a CSV.
    class ColumnValue
      # @param column [String]
      # @param value [String]
      # @param mapping [CollectionSpace::Mapper::ColumnMapping]
      def self.create(
        column:,
        value:,
        mapping:
      )
        case mapping.xpath.length
        when 0
          ColumnValue.new(
            column: column,
            value: value,
            mapping: mapping
          )
        when 1
          MultivalColumnValue.new(
            column: column,
            value: value,
            mapping: mapping
          )
        when 2
          GroupColumnValue.new(
            column: column,
            value: value,
            mapping: mapping
          )
        when 3
          # bonsai conservation fertilizerToBeUsed is the only field like this
          GroupMultivalColumnValue.new(
            column: column,
            value: value,
            mapping: mapping
          )
        when 4
          SubgroupColumnValue.new(
            column: column,
            value: value,
            mapping: mapping
          )
        end
      end

      # @param column [String]
      # @param value [String]
      # @param mapping [CollectionSpace::Mapper::ColumnMapping]
      def initialize(
        column:,
        value:,
        mapping:
      )
        @column = column.downcase
        @value = value
        @mapping = mapping
      end

      def split
        [@value.strip]
      end
    end
  end
end

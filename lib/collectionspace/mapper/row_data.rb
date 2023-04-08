# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # @todo Finish implementing
    #
    # Represents a row of data from a CSV, and ends up having some
    #   responsibility for coordinating the processing of the row
    class RowData
      attr_reader :columns

      def initialize(
        datahash,
        recmapper = CollectionSpace::Mapper.recordmapper
      )
        @recmapper = recmapper
        @columns = datahash.map do |column, value|
          CollectionSpace::Mapper::ColumnValue.create(
            column: column,
            value: value,
            mapping: @recmapper.mappings.lookup(column)
          )
        end
      end
    end
  end
end

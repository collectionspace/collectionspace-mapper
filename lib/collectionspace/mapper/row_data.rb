# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # represents a row of data from a CSV.
    # ends up having some responsibility for coordinating the processing of the row
    class RowData
      attr_reader :columns

      def initialize(datahash, recmapper)
        @recmapper = recmapper
        @columns = datahash.map do |column, value|
          CollectionSpace::Mapper::ColumnValue.create(column: column,
            value: value,
            recmapper: @recmapper,
            mapping: @recmapper.mappings.lookup(column))
        end
      end
    end
  end
end

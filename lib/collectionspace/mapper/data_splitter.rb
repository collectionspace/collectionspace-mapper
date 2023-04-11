# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataSplitter
      attr_reader :result

      def initialize(data)
        @data = data.strip
        @delim = CollectionSpace::Mapper.batch.delimiter
        @sgdelim = CollectionSpace::Mapper.batch.subgroup_delimiter
      end

      private

      attr_reader :data, :delim, :sgdelim
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataSplitter
      attr_reader :data, :result

      # @todo appconfig remove config arg
      def initialize(data, config = nil)
        @data = data.strip
        @delim = CollectionSpace::Mapper.batch.delimiter
        @sgdelim = CollectionSpace::Mapper.batch.subgroup_delimiter
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataSplitter
      attr_reader :data, :result

      def initialize(data, config)
        @data = data.strip
        @config = config
        @delim = @config.delimiter
        @sgdelim = @config.subgroup_delimiter
      end
    end
  end
end

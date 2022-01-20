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

    class SimpleSplitter < DataSplitter
      def initialize(data, config)
        super
        # negative limit parameter turns off suppression of trailing empty fields
        @result = @data.split(@delim, -1).map{ |e| e.strip }
      end
    end

    class SubgroupSplitter < DataSplitter
      def initialize(data, config)
        super
        # negative limit parameter turns off suppression of trailing empty fields
        groups = @data.split(@delim, -1).map{ |e| e.strip }
        @result = groups.map{ |g| g.split(@sgdelim, -1).map{ |e| e.strip } }
      end
    end
  end
end

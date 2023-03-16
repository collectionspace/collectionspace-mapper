# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class SubgroupSplitter < DataSplitter
      def initialize(data, config)
        super
        # negative limit parameter turns off suppression of trailing empty
        #   fields
        groups = @data.split(@delim, -1).map { |e| e.strip }
        @result = groups.map { |g| g.split(@sgdelim, -1).map { |e| e.strip } }
      end
    end
  end
end

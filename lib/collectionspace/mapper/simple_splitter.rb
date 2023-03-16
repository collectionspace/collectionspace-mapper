# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class SimpleSplitter < DataSplitter
      def initialize(data, config)
        super
        # negative limit parameter turns off suppression of trailing empty
        #   fields
        @result = @data.split(@delim, -1).map { |e| e.strip }
      end
    end
  end
end

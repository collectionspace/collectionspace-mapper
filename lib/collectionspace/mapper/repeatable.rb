# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # special behavior for repeatable fields (or field groups) that are NOT
    #   subgroupable
    module Repeatable
      def split
        @value.split(CollectionSpace::Mapper.batch.delimiter)
          .map(&:strip)
      end
    end
  end
end

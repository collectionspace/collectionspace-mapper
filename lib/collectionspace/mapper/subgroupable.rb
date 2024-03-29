# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # special behavior for repeatable fields (or field groups) within a parent
    #   repeatable field group
    module Subgroupable
      def split
        hash = {}
        groups = @value.split(CollectionSpace::Mapper.batch.delimiter)
          .map(&:strip)
        groups.each_with_index do |group, ind|
          hash[ind + 1] =
            group.split(CollectionSpace::Mapper.batch.subgroup_delimiter)
              .map(&:strip)
        end
        hash
      end
    end
  end
end

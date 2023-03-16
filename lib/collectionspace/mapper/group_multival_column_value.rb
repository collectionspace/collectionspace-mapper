# frozen_string_literal: true

require_relative "column_value"
require_relative "subgroupable"

module CollectionSpace
  module Mapper
    # a column value destined for a single/non-subgrouped repeating field within a repeating field group
    class GroupMultivalColumnValue < ColumnValue
      include Subgroupable
    end
  end
end

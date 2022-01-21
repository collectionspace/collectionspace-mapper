# frozen_string_literal: true

require_relative 'column_value'
require_relative 'subgroupable'

module CollectionSpace
  module Mapper
    # a column value destined for repeating subgroups of fields within a repeating field group
    class SubgroupColumnValue < ColumnValue
      include Subgroupable
    end
  end
end

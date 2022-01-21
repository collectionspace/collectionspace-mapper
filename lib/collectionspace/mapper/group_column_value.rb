# frozen_string_literal: true

require_relative 'column_value'
require_relative 'repeatable'

module CollectionSpace
  module Mapper
    # a column value destined for a field in a repeating field group
    class GroupColumnValue < ColumnValue
      include Repeatable
    end
  end
end

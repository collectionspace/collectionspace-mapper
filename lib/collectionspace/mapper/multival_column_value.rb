# frozen_string_literal: true

require_relative 'column_value'
require_relative 'repeatable'

module CollectionSpace
  module Mapper
    # a column value destined for a multivalue field nested directly under a namespace element
    class MultivalColumnValue < ColumnValue
      include Repeatable
    end
  end
end

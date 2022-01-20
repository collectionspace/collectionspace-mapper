# frozen_string_literal: true

require_relative 'transformer'
require_relative 'find_replace_operation'

module CollectionSpace
  module Mapper
    # carries out a find/replace operation on a given value
    class FindReplaceTransformer < Transformer
      def initialize(transform:)
        super
        @operations = transform.map{ |operation| FindReplaceOperation.create(operation) }
      end

      def transform(value)
        return value if value.blank?

        newval = value
        @operations.each{ |operation| newval = operation.perform(newval) }
        newval
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # Mixin module for combining term type and subtype in a consistent way
    #   across other classes/modules
    # @note Implementation assumes this will be included where calling `type`
    #   and `subtype` return as expected
    module TypeSubtypeable
      private

      def type_subtype
        "#{type}/#{subtype}"
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class MultiColumnRequiredField < RequiredField
      # @todo DRY up last part of these messages
      def missing_message
        "required field missing: #{@field}. At least one of the following "\
          "fields must be present: #{@columns.join(", ")}"
      end

      def empty_message
        "required field empty: #{@field}. At least one of the following "\
          "fields must be populated: #{@columns.join(", ")}"
      end
    end
  end
end

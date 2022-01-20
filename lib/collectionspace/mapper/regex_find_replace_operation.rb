# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # a single find/replace operation -- one step in a FindReplaceTransformer
    class RegexFindReplaceOperation < FindReplaceOperation
      def perform(value)
        return value if value.blank?

        value.gsub(Regexp.new(@find), @replace)
      end
    end
  end
end

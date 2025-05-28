# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # Mixin module for case swapping of strings
    module CaseSwappable
      private

      def case_swap(string)
        string.match?(/[A-Z]/) ? string.downcase : string.capitalize
      end
    end
  end
end

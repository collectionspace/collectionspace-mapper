# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # Mixin module for case swapping of strings
    module CaseSwappable
      private

      def case_swap(string)
        string.match?(/[A-Z]/) ? string.downcase : string.capitalize
      end

      def case_swap_element(array, idx)
        array.insert(idx, case_swap(array[idx]))
        array.delete_at(idx + 1)
        array
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Identifiers
      class ShortIdentifier
        def initialize(term:)
          @term = term
        end

        def value
          prepped_term
        end

        private

        def prepped_term
          @term.gsub(/\W/, '')
        end
      end
    end
  end
end

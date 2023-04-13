# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Identifiers
      class AuthorityShortIdentifier < ShortIdentifier
        def initialize(**opts)
          super
        end

        def call
          "#{prepped_term}#{hashed_term}"
        end

        private

        def hashed_term
          XXhash.xxh32(prepped_term)
        end
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Identifiers
      class ShortIdentifier
        class << self
          def call(term)
            self.new(term: term).call
          end
        end

        def initialize(term:)
          @term = term
        end

        def call
          prepped_term
        end

        private

        attr_reader :term

        def prepped_term
          term.gsub(/\W/, "")
        end
      end
    end
  end
end

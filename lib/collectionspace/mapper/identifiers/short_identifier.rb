# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Identifiers
      class ShortIdentifier
        class << self
          def call(term, mode = "normalized")
            term.gsub(/\W/, "")
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Identifiers
      class AuthorityShortIdentifier
        class << self
          def call(term, mode = "normalized")
            case mode
            when "normalized"
              prepped = prepped(term)
              "#{prepped}#{hashed(prepped)}"
            when "exact"
              "#{prepped(term)}#{hashed(term)}"
            end
          end

          private

          def prepped(term)
            result = term.gsub(/\W/, "")
            return result unless result.empty?

            # All non-Latin characters are removed from
            #   shortIdentifiers as created by the CollectionSpace
            #   application. However, CollectionSpace itself is able
            #   to generate a unique hash value from the string to use
            #   as the shortIdentifier value. We need to provide a
            #   unique string that meets the Latin alphanumeric
            #   requirements of a shortIdentifier value, so that
            #   unique strings consisting fully of non-Latin
            #   characters can be loaded without being flagged as
            #   duplicates of one another.
            "spec#{term.bytes.join("b")}"
          end

          def hashed(term)
            XXhash.xxh32(term)
          end
        end
      end
    end
  end
end

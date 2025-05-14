# frozen_string_literal: true

require "dry/monads"

module CollectionSpace
  module Mapper
    module VocabularyTerms
      KNOWN_OPT_FIELDS = %w[description source sourcePage termStatus].freeze

      # Sets up a class with client context, that can process terms from
      #   multiple vocabularies
      class PayloadBuilder
        extend Dry::Monads[:result]

        # rubocop:disable Layout/LineLength
        # @param domain [String] CS client domain
        # @param csid [String] CSID of vocabulary
        # @param name [String] machine name of vocabulary
        # @param term [String] to be created
        # @param termid [String] shortidentifier value of term
        # @param opt_fields [nil, Hash]
        def self.call(domain:, csid:, name:, term:, termid:, opt_fields: nil)
          payload = <<~XML
            <?xml version="1.0" encoding="utf-8" standalone="yes"?>
            <document name="vocabularyitems">
                <ns2:vocabularyitems_common
                   xmlns:ns2="http://collectionspace.org/services/vocabulary"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                   <inAuthority>#{csid}</inAuthority>
                   <displayName>#{term}</displayName>
                   <shortIdentifier>#{termid}</shortIdentifier>
                   <refName>
                     urn:cspace:#{domain}:vocabularies:name(#{name}):item:name(#{termid})'#{term}'
                   </refName>#{opt_fields_to_s(opt_fields)}
                </ns2:vocabularyitems_common>
            </document>
          XML
          Success(payload)
        end
        # rubocop:enable Layout/LineLength

        private

        def self.opt_fields_to_s(opt_fields)
          return "" unless opt_fields

          keep_fields = opt_fields.select do |key, val|
            KNOWN_OPT_FIELDS.include?(key)
          end
          return "" if keep_fields.empty?

          keep_fields.map { |key, value| "<#{key}>#{value}</#{key}>" }
            .join("\n")
        end
      end
    end
  end
end

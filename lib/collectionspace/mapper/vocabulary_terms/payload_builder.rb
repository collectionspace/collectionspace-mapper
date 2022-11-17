# frozen_string_literal: true

require 'dry/monads'

module CollectionSpace
  module Mapper
    module VocabularyTerms
      # Sets up a class with client context, that can process terms from multiple
      #   vocabularies
      class PayloadBuilder
        extend Dry::Monads[:result]

        # @param domain [String] CS client domain
        # @param csid [String] CSID of vocabulary
        # @param name [String] machine name of vocabulary
        # @param term [String] to be created
        # @param termid [String] shortidentifier value of term
        def self.call(domain:, csid:, name:, term:, termid:)
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
                   </refName>
                </ns2:vocabularyitems_common>
            </document>
            XML
          Success(payload)
        end
      end
    end
  end
end

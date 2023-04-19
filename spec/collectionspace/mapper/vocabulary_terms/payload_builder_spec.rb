# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::VocabularyTerms::PayloadBuilder do
  subject(:builder){ described_class }

  describe ".call" do
    it "returns as expected" do
      result = builder.call(
        domain: "DOMAIN",
        csid: "CSID",
        name: "NAME",
        term: "TERM",
        termid: "TERMID"
      )
      expected = <<~XML
        <?xml version="1.0" encoding="utf-8" standalone="yes"?>
        <document name="vocabularyitems">
            <ns2:vocabularyitems_common
               xmlns:ns2="http://collectionspace.org/services/vocabulary"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
               <inAuthority>CSID</inAuthority>
               <displayName>TERM</displayName>
               <shortIdentifier>TERMID</shortIdentifier>
               <refName>
                 urn:cspace:DOMAIN:vocabularies:name(NAME):item:name(TERMID)'TERM'
               </refName>
            </ns2:vocabularyitems_common>
        </document>
      XML
      expect(result).to be_a(Dry::Monads::Success)
      expect(result.value!).to eq(expected)
    end
  end
end

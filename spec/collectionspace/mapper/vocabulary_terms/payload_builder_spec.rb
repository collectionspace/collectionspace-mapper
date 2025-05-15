# frozen_string_literal: true

require "spec_helper"

def to_doc(str) = Nokogiri::XML(str) { |c| c.noblanks }

RSpec.describe CollectionSpace::Mapper::VocabularyTerms::PayloadBuilder do
  subject(:builder) { described_class }

  describe ".call" do
    it "returns as expected without opt_fields" do
      result = builder.call(
        domain: "DOMAIN",
        csid: "CSID",
        name: "NAME",
        term: "TERM",
        termid: "TERMID"
      )

      # rubocop:disable Layout/LineLength
      expected = <<~XML
        <?xml version="1.0" encoding="utf-8" standalone="yes"?>
        <document name="vocabularyitems">
            <ns2:vocabularyitems_common
               xmlns:ns2="http://collectionspace.org/services/vocabulary"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
               <inAuthority>CSID</inAuthority>
               <shortIdentifier>TERMID</shortIdentifier>
               <refName>urn:cspace:DOMAIN:vocabularies:name(NAME):item:name(TERMID)'TERM'</refName>
               <displayName>TERM</displayName>
            </ns2:vocabularyitems_common>
        </document>
      XML
      # rubocop:enable Layout/LineLength
      expect(result).to be_a(Dry::Monads::Success)
      got_str = result.value!
      got_doc = to_doc(got_str).to_xml
      exp_doc = to_doc(expected).to_xml
      expect(got_doc).to eq(exp_doc)
    end

    it "returns as expected with no valid opt_fields" do
      result = builder.call(
        domain: "DOMAIN",
        csid: "CSID",
        name: "NAME",
        term: "TERM",
        termid: "TERMID",
        opt_fields: {"badField" => "foo"}
      )

      # rubocop:disable Layout/LineLength
      expected = <<~XML
        <?xml version="1.0" encoding="utf-8" standalone="yes"?>
        <document name="vocabularyitems">
            <ns2:vocabularyitems_common
               xmlns:ns2="http://collectionspace.org/services/vocabulary"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
               <inAuthority>CSID</inAuthority>
               <shortIdentifier>TERMID</shortIdentifier>
               <refName>urn:cspace:DOMAIN:vocabularies:name(NAME):item:name(TERMID)'TERM'</refName>
               <displayName>TERM</displayName>
            </ns2:vocabularyitems_common>
        </document>
      XML
      # rubocop:enable Layout/LineLength
      expect(result).to be_a(Dry::Monads::Success)
      got_str = result.value!
      got_doc = to_doc(got_str).to_xml
      exp_doc = to_doc(expected).to_xml
      expect(got_doc).to eq(exp_doc)
    end

    it "returns as expected with valid opt_fields" do
      result = builder.call(
        domain: "DOMAIN",
        csid: "CSID",
        name: "NAME",
        term: "TERM",
        termid: "TERMID",
        opt_fields: {"badField" => "foo", "source" => "bar & baz",
                     "sourcePage" => "2", "description" => "\u{1F4A3}"}
      )
      # rubocop:disable Layout/LineLength
      expected = <<~XML
        <?xml version="1.0" encoding="utf-8" standalone="yes"?>
        <document name="vocabularyitems">
          <ns2:vocabularyitems_common
             xmlns:ns2="http://collectionspace.org/services/vocabulary"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
               <inAuthority>CSID</inAuthority>
               <shortIdentifier>TERMID</shortIdentifier>
               <refName>urn:cspace:DOMAIN:vocabularies:name(NAME):item:name(TERMID)'TERM'</refName>
               <source>bar &amp; baz</source>
               <sourcePage>2</sourcePage>
               <description></description>
               <displayName>TERM</displayName>
          </ns2:vocabularyitems_common>
         </document>
      XML
      # rubocop:enable Layout/LineLength
      expect(result).to be_a(Dry::Monads::Success)
      got_str = result.value!
      got_doc = to_doc(got_str).to_xml
      exp_doc = to_doc(expected).to_xml
      expect(got_doc).to eq(exp_doc)
    end
  end
end

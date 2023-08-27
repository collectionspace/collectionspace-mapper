# frozen_string_literal: true

require "spec_helper"

class TermClass
  attr_accessor :errors

  include CollectionSpace::Mapper::TermSearchable

  attr_reader :type, :subtype, :handler
  def initialize(type, subtype, handler)
    @type = type
    @subtype = subtype
    @handler = handler
    @errors = []
  end
end

RSpec.describe CollectionSpace::Mapper::TermSearchable,
  vcr: "core_domain_check" do
  subject(:term) do
    TermClass.new(termtype, termsubtype, handler)
  end

  let(:handler) do
    setup_handler(
      mapper: "core_6-1-0_collectionobject",
      config: config
    )
  end
  let(:baseconfig) { {delimiter: ";"} }
  let(:customcfg) { {} }
  let(:config) { baseconfig.merge(customcfg) }

  let(:termtype) { "conceptauthorities" }
  let(:termsubtype) { "concept" }

  describe "#in_cache?" do
    let(:result) { term.send(:in_cache?, val) }
    context "when not in cache" do
      let(:val) { "Tiresias" }
      it "returns false" do
        expect(result).to be false
      end
    end

    context "when in cache" do
      let(:val) { "Test" }
      it "returns true" do
        expect(result).to be true
      end
    end

    context "when captitalized form is in cache" do
      let(:val) { "test" }
      it "returns true" do
        expect(result).to be true
      end
    end
  end

  describe "#cached_as_unknown?" do
    let(:result) { term.send(:cached_as_unknown?, val) }
    let(:val) { "blahblahblah" }

    context "when not cached as unknown value" do
      it "returns false" do
        handler.termcache
          .remove("unknownvalue", "#{termtype}/#{termsubtype}", val)
        expect(result).to be false
      end
    end

    context "when cached as unknown value" do
      it "returns true" do
        handler.termcache
          .put("unknownvalue", "#{termtype}/#{termsubtype}", val, nil)
        expect(result).to be true
      end
    end
  end

  describe "#cached_term" do
    let(:result) { term.send(:cached_term, val) }
    context "when not in cache" do
      let(:val) { "Tiresias" }
      it "returns nil" do
        expect(result).to be_nil
      end
    end

    context "when in cache" do
      let(:val) { "Test" }
      it "returns refname urn" do
        expected = "urn:cspace:c.core.collectionspace.org:conceptauthorities:"\
          "name(concept):item:name(Test1599650854716)'Test'"
        expect(result).to eq(expected)
      end
    end

    context "when capitalized form is in cache" do
      let(:val) { "test" }
      it "returns refname urn" do
        expected = "urn:cspace:c.core.collectionspace.org:conceptauthorities"\
          ":name(concept):item:name(Test1599650854716)'Test'"
        expect(result).to eq(expected)
      end
    end
  end

  describe "#searched_term" do
    let(:termtype) { "vocabularies" }
    let(:termsubtype) { "publishto" }
    let(:result) do
      term.send(:searched_term, val, :refname, termtype, termsubtype)
    end

    context "when val exists in instance", vcr: "vocab_publishto_All" do
      let(:val) { "All" }
      it "returns refname urn" do
        expected = "urn:cspace:core.collectionspace.org:vocabularies:name"\
          "(publishto):item:name(all)'All'"
        expect(result).to eq(expected)
      end
    end

    context "when case-swapped val exists in instance",
      vcr: "vocab_publishto_all" do
      let(:val) { "all" }
      it "returns refname urn" do
        expected = "urn:cspace:core.collectionspace.org:vocabularies:name"\
          "(publishto):item:name(all)'All'"
        expect(result).to eq(expected)
      end
    end
  end

  # also covers lookup_obj_csid
  describe "#obj_csid" do
    let(:type) { "collectionobjects" }
    let(:termsubtype) { nil }
    let(:result) { term.send(:obj_csid, objnum, type) }

    context "when in cache" do
      let(:objnum) { "Hierarchy Test 001" }

      it "returns csid" do
        expect(result).to eq("7976-7265-3715-6363")
      end
    end

    context "when not in cache", vcr: "obj_csid_QA_TEST_001" do
      let(:objnum) { "QA TEST 001" }
      it "returns csid" do
        expect(result).to eq("56c04f5f-32b9-4f1d-8a4b")
      end
    end
  end

  describe "#term_csid" do
    let(:result) { term.send(:term_csid, val) }
    context "when in cache" do
      let(:val) { "Sample Concept 1" }
      it "returns csid" do
        # it 'returns csid', :skip => 'does not cause mapping to fail, so we
        #   live with technical incorrectness for now' do
        expect(result).to eq("3736-2250-1869-4155")
      end
    end

    context "when not in cache", vcr: "term_csid_QA_TEST_Concept_2" do
      let(:val) { "QA TEST Concept 2" }
      it "returns csid" do
        expect(result).to eq("8a76c4d7-d66d-451c-abee")
      end
    end
  end
end

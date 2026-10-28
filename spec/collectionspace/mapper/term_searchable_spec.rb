# frozen_string_literal: true

require "spec_helper"

class TermClass
  attr_accessor :errors

  include CollectionSpace::Mapper::TermSearchable

  attr_reader :type, :subtype, :handler, :response
  def initialize(type, subtype, handler)
    @type = type
    @subtype = subtype
    @handler = handler
    @response = CollectionSpace::Mapper::Response.new({}, handler)
    @errors = []
  end

  def column = "foo"
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

  describe "#searched_term" do
    let(:termtype) { "vocabularies" }
    let(:termsubtype) { "publishto" }
    let(:result) do
      term.send(:searched_term, val, :refname, termtype, termsubtype)
    end

    context "when val exists in instance", vcr: "vocab_publishto_cap_all" do
      let(:val) { "All" }
      it "returns refname urn" do
        expected = "urn:cspace:core.collectionspace.org:vocabularies:name"\
          "(publishto):item:name(all)'All'"
        expect(result).to eq(expected)
      end
    end

    context "when case-swapped val exists in instance",
      vcr: "vocab_publishto_lower_all" do
        let(:val) { "all" }
        it "returns refname urn" do
          expected = "urn:cspace:core.collectionspace.org:vocabularies:name"\
            "(publishto):item:name(all)'All'"
          expect(result).to eq(expected)
          expect(term.response.warnings).to include({
            category: "case_insensitive_match",
            message: "Searched: all. Using: All",
            field: "foo"
          })
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

    context "with single record type handler" do
      let(:handler) do
        setup_single_record_type_handler(
          mapper: "https://raw.githubusercontent.com/collectionspace/"\
            "cspace-config-untangler/refs/heads/main/data/mappers/"\
            "community_profiles/release_8_1_1/core/"\
            "core_10-0-2_collectionobject.json",
          config: config
        )
      end

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

    context "with single record type handler" do
      let(:handler) do
        setup_single_record_type_handler(
          mapper: "https://raw.githubusercontent.com/collectionspace/"\
            "cspace-config-untangler/refs/heads/main/data/mappers/"\
            "community_profiles/release_8_1_1/core/"\
            "core_10-0-2_collectionobject.json",
          config: config
        )
      end

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
end

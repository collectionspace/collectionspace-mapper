# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Response do
  subject(:response) { described_class.new(data, handler) }

  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper,
      config: config
    )
  end
  let(:profile) { "core" }
  let(:mapper) { "core_6-1-0_collectionobject" }
  let(:baseconfig) { {delimiter: ";"} }
  let(:customcfg) { {} }
  let(:config) { baseconfig.merge(customcfg) }

  let(:data) do
    {
      "objectNumber" => "123",
      "collection" => "Permanent Collection",
      "title" => "",
      "numberValue" => nil
    }
  end

  describe ".new", vcr: "core_domain_check" do
    it "populates orig_data" do
      expect(response.orig_data).to eq(data)
    end
  end

  describe "#merged_data", vcr: "core_domain_check" do
    let(:result) { response.merged_data }

    it "downcases keys" do
      expect(result.keys).to eq(%w[objectnumber collection title numbervalue])
    end

    context "with non-conflicting default values specified" do
      let(:customcfg) do
        {default_values: {"publishTo" => "DPLA;Omeka"}}
      end

      it "populates merged_data with changes" do
        expect(result["publishto"]).to eq("DPLA;Omeka")
      end
    end

    context "with conflicting default values specified" do
      let(:customcfg) do
        {default_values: {
          "publishTo" => "DPLA;Omeka",
          "collection" => "Temp"
        }}
      end

      it "populates merged_data with changes" do
        expect(result["publishto"]).to eq("DPLA;Omeka")
        expect(result["collection"]).to eq("Permanent Collection")
      end
    end

    context "with conflicting default values specified and force_defaults" do
      let(:customcfg) do
        {
          default_values: {
            "publishTo" => "DPLA;Omeka",
            "collection" => "Temp"
          },
          force_defaults: true
        }
      end

      it "populates merged_data with changes" do
        expect(result["publishto"]).to eq("DPLA;Omeka")
        expect(result["collection"]).to eq("Temp")
      end
    end
  end

  describe "#set_record_status", vcr: "core_domain_check" do
    let(:checker) { double("Checker") }
    let(:data) { {field: "foo"} }

    context "when new" do
      it "sets status as expected" do
        handler.config.status_checker = checker
        allow(checker).to receive(:call).and_return(
          {status: :new}
        )
        response.set_record_status
        expect(response.record_status).to eq(:new)
        expect(response.csid).to be_nil
      end
    end

    context "when existing" do
      it "sets status as expected" do
        handler.config.status_checker = checker
        allow(checker).to receive(:call).and_return(
          {
            status: :existing,
            csid: "csid",
            uri: "uri",
            refname: "refname"
          }
        )
        response.set_record_status
        expect(response.record_status).to eq(:existing)
        expect(response.csid).to eq("csid")
        expect(response.uri).to eq("uri")
        expect(response.refname).to eq("refname")
      end
    end

    context "when checking is turned off" do
      let(:customcfg) { {check_record_status: false} }

      it "sets status as expected" do
        response.set_record_status
        expect(response.record_status).to eq(:new)
        expect(response.csid).to be_nil
      end
    end
  end

  describe "#valid?", vcr: "botgarden_domain_check" do
    let(:result) { response.valid? }
    let(:profile) { "botgarden" }
    let(:mapper) { "botgarden_2-0-1_taxon-local" }

    context "when there are no errors" do
      let(:data) { {"termDisplayName" => "Tanacetum"} }

      it "returns true" do
        expect(result).to be true
      end
    end
    context "when there is one or more errors" do
      let(:data) { {"taxonName" => "Tanacetum"} }
      it "returns false" do
        expect(result).to be false
      end
    end
  end

  describe "#xml", vcr: "botgarden_taxon_tanacetum" do
    let(:profile) { "botgarden" }
    let(:mapper) { "botgarden_2-0-1_taxon-local" }

    let(:data) {
      {"termDisplayName" => "Tanacetum;Tansy", "termStatus" => "made up"}
    }

    context "when there is a doc", services_call: true do
      it "returns string" do
        expect(response.map.xml).to be_a(String)
      end
    end

    context "when there is no doc" do
      it "returns nil" do
        expect(response.xml).to be_nil
      end
    end
  end

  describe "#xpaths", vcr: "core_domain_check" do
    let(:result) { response.xpaths }

    context "when authority record" do
      let(:mapper) { "core_6-1-0_place-local" }
      let(:data) { {"termdisplayname" => "Silk Hope"} }

      it "keeps mapping for shortIdentifier in xphash" do
        mappings = result["places_common"].mappings
          .map(&:fieldname)
        expect(mappings).to include("shortIdentifier")
      end

      it "removes xpaths to which no fields map" do
        expect(result.length).to eq(2)
      end
    end
  end

  describe "#terms", vcr: "core_domain_check" do
    let(:customcfg) { {delimiter: "|", response_mode: "verbose"} }
    let(:processed) { response.map }

    context "with some terms found and some terms not found" do
      let(:result) { processed.terms.reject { |t| t.found? } }

      vcr_found_opts = {
        cassette_name: "datahandler_uncached_found_terms",
        record: :new_episodes
      }
      context "with terms in instance but not in cache",
        vcr: vcr_found_opts do
          let(:data) do
            {
              "objectNumber" => "20CS.001.0002",
              # vocabulary, in instance, in cache
              "titleLanguage" => "English",
              # authority, in instance (caseswapped), not in cache
              "namedCollection" => "Test Collection"
            }
          end

          it "returns expected found values" do
            expect(result.length).to eq(0)
          end
        end

      vcr_unfound_opts = {
        cassette_name: "datahandler_uncached_unfound_terms",
        record: :new_episodes
      }
      context "with terms in instance but not in cache, and not in instance",
        vcr: vcr_unfound_opts do
          let(:data) do
            {
              "objectNumber" => "20CS.001.0001",
              # English is in cache; Klingon is not in instance or cache
              "titleLanguage" => "English| Klingon",
              # In instance (caseswapped)
              "namedCollection" => "Test collection"
            }
          end

          it "returns expected found values" do
            expect(result.length).to eq(1)
          end
        end
    end

    unfound_term_opts = {
      cassette_name: "datahandler_tag_unfound_terms",
      record: :new_episodes
    }
    it "tags all un-found terms as such", vcr: unfound_term_opts do
      data1 = {
        "objectNumber" => "1",
        # vocabulary - in instance, not in cache
        "publishTo" => "All",
        # authority - in instance, not in cache
        "namedCollection" => "QA TARGET Work"
      }
      data2 = {
        "objectNumber" => "2",
        # vocabulary - now in cache
        "publishTo" => "All",
        # authority - now in cache
        "namedCollection" => "QA TARGET Work",
        # authority - not in instance, not in cache
        "contentConceptAssociated" => "Birbs"
      }

      resp1 = CollectionSpace::Mapper::Response.new(data1, handler)
      resp2 = CollectionSpace::Mapper::Response.new(data2, handler)

      handler.process(resp1)

      result = handler.process(resp2)
        .terms
        .select { |t| !t.found? }
      expect(result.length).to eq(1)
    end
  end

  describe "#map", vcr: "botgarden_taxon_tanacetum" do
    let(:result) { response.map }
    let(:profile) { "botgarden" }
    let(:mapper) { "botgarden_2-0-1_taxon-local" }
    let(:data) {
      {"termDisplayName" => "Tanacetum;Tansy", "termStatus" => "made up"}
    }

    it "returns as expected" do
      expect(result.doc).to be_a(Nokogiri::XML::Document)
      expect(result.warnings).not_to be_empty
      expect(result.identifier).not_to be_empty
      expect(result.orig_data).to be_a(Hash)
      expect(result.merged_data).to be_empty
      expect(result.split_data).to be_empty
      expect(result.transformed_data).to be_empty
      expect(result.combined_data).to be_empty
    end

    context "when response_mode = verbose in config",
      vcr: "botgarden_taxon_tanacetum" do
        let(:customcfg) { {response_mode: "verbose"} }

        it "returns as expected" do
          expect(result.doc).to be_a(Nokogiri::XML::Document)
          expect(result.warnings).not_to be_empty
          expect(result.identifier).not_to be_empty
          expect(result.orig_data).to be_a(Hash)
          expect(result.merged_data).not_to be_empty
          expect(result.split_data).not_to be_empty
          expect(result.transformed_data).not_to be_empty
          expect(result.combined_data).not_to be_empty
        end
      end
  end
end

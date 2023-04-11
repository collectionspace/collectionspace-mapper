# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Response do
  after{ CollectionSpace::Mapper.reset_config }

  let(:handler) do
    CollectionSpace::Mapper.data_handler
  end

  describe "#new" do
    let(:result){ described_class.new(data) }
    let(:data) do
      {
        'objectnumber'=>'123',
        "collection" => "Permanent Collection"
      }
    end

    it "populates orig_data and merged_data with no changes" do
      expect(result.orig_data).to eq(data)
      expect(result.merged_data).to eq(data)
    end

    context "with non-conflicting default values specified" do
      before do
        CollectionSpace::Mapper.config.batch.delimiter = ";"
        CollectionSpace::Mapper.config.batch.default_values = {
          "publishTo" => "DPLA;Omeka"
        }
      end

      it "populates orig_data with no changes" do
        expect(result.orig_data["publishTo"]).to be_nil
      end

      it "populates merged_data with changes" do
        expect(result.merged_data["publishto"]).to eq("DPLA;Omeka")
      end
    end

    context "with conflicting default values specified" do
      before do
        CollectionSpace::Mapper.config.batch.delimiter = ";"
        CollectionSpace::Mapper.config.batch.default_values = {
          "publishTo" => "DPLA;Omeka",
          "collection"=> "Temp"
        }
      end
      let(:data) do
        {
          'objectnumber'=>'123',
          "collection" => "Permanent Collection"
        }
      end

      it "populates orig_data with no changes" do
        expect(result.orig_data["publishTo"]).to be_nil
        expect(result.orig_data["collection"]).to eq("Permanent Collection")
      end

      it "populates merged_data with changes" do
        expect(result.merged_data["publishto"]).to eq("DPLA;Omeka")
        expect(result.merged_data["collection"]).to eq("Permanent Collection")
      end
    end

    context "with conflicting default values specified and force_defaults" do
      before do
        CollectionSpace::Mapper.config.batch.delimiter = ";"
        CollectionSpace::Mapper.config.batch.default_values = {
          "publishTo" => "DPLA;Omeka",
          "collection"=> "Temp"
        }
        CollectionSpace::Mapper.config.batch.force_defaults = true
      end
      let(:data) do
        {
          'objectnumber'=>'123',
          "collection" => "Permanent Collection"
        }
      end

      it "populates orig_data with no changes" do
        expect(result.orig_data["publishTo"]).to be_nil
        expect(result.orig_data["collection"]).to eq("Permanent Collection")
      end

      it "populates merged_data with changes" do
        expect(result.merged_data["publishto"]).to eq("DPLA;Omeka")
        expect(result.merged_data["collection"]).to eq("Temp")
      end
    end
  end

  describe "#set_record_status" do
    let(:checker){ double('Checker') }
    let(:response){ described_class.new(data, checker) }
    let(:data){ { field: 'foo'} }

    context "when new" do
      it "sets status as expected" do
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
        allow(checker).to receive(:call).and_return(
          {
            status: :existing,
            csid: 'csid',
            uri: 'uri',
            refname: 'refname'
          }
        )
        response.set_record_status
        expect(response.record_status).to eq(:existing)
        expect(response.csid).to eq('csid')
        expect(response.uri).to eq('uri')
        expect(response.refname).to eq('refname')
      end
    end

    context "when checking is turned off" do
      before do
        CollectionSpace::Mapper.config.batch.check_record_status = false
      end

      it "sets status as expected" do
        response.set_record_status
        expect(response.record_status).to eq(:new)
        expect(response.csid).to be_nil
      end
    end
  end

  describe "#valid?" do
    before do
      setup_handler(
        profile: 'botgarden',
        mapper_path: "spec/fixtures/files/mappers/release_6_1/botgarden/"\
          "botgarden_2-0-1_taxon-local.json"
      )
      CollectionSpace::Mapper.config.batch.delimiter = ';'
    end

    let(:response){ described_class.new(data) }

    context "when there are no errors" do
      let(:data) { {"termDisplayName" => "Tanacetum"} }

      it "returns true" do
        expect(response.valid?).to be true
      end
    end
    context "when there is one or more errors" do
      let(:data) { {"taxonName" => "Tanacetum"} }
      it "returns false" do
        expect(response.valid?).to be false
      end
    end
  end

  context "when response_mode = verbose in config",
    vcr: "botgarden_taxon_tanacetum" do
      before do
        setup_handler(
          profile: 'botgarden',
          mapper_path: "spec/fixtures/files/mappers/release_6_1/botgarden/"\
            "botgarden_2-0-1_taxon-local.json"
        )
        CollectionSpace::Mapper.config.batch.delimiter = ';'
        CollectionSpace::Mapper.config.batch.response_mode = 'verbose'
      end

      let(:data) {
        {"termDisplayName" => "Tanacetum;Tansy", "termStatus" => "made up"}
      }
      let(:response) do
        resp = described_class.new(data)
        handler.process(resp)
      end

      it "returns Response with populated doc" do
        expect(response.doc).to be_a(Nokogiri::XML::Document)
      end
      it "returns Response with populated warnings" do
        expect(response.warnings).not_to be_empty
      end
      it "returns Response with populated identifier" do
        expect(response.identifier).not_to be_empty
      end
      it "returns Response with Hash of orig_data" do
        expect(response.orig_data).to be_a(Hash)
      end
      it "returns Response with populated merged_data" do
        expect(response.merged_data).not_to be_empty
      end
      it "returns Response with populated split_data" do
        expect(response.split_data).not_to be_empty
      end
      it "returns Response with populated transformed_data" do
        expect(response.transformed_data).not_to be_empty
      end
      it "returns Response with populated combined_data" do
        expect(response.combined_data).not_to be_empty
      end
    end

  describe "#normal", services_call: true,
    vcr: "botgarden_taxon_tanacetum" do
        before do
          setup_handler(
            profile: 'botgarden',
            mapper_path: "spec/fixtures/files/mappers/release_6_1/botgarden/"\
              "botgarden_2-0-1_taxon-local.json"
          )
          CollectionSpace::Mapper.config.batch.delimiter = ';'
        end

        let(:data) {
          {"termDisplayName" => "Tanacetum;Tansy", "termStatus" => "made up"}
        }
        let(:response) do
          resp = described_class.new(data)
          handler.process(resp).normal
        end

        it "returns Response with populated doc" do
          expect(response.doc).to be_a(Nokogiri::XML::Document)
        end
        it "returns Response with populated warnings" do
          expect(response.warnings).not_to be_empty
        end
        it "returns Response with populated identifier" do
          expect(response.identifier).not_to be_empty
        end
        it "returns Response with Hash of orig_data" do
          expect(response.orig_data).to be_a(Hash)
        end
        it "returns Response with unpopulated merged_data" do
          expect(response.merged_data).to be_empty
        end
        it "returns Response with unpopulated split_data" do
          expect(response.split_data).to be_empty
        end
        it "returns Response with unpopulated transformed_data" do
          expect(response.transformed_data).to be_empty
        end
        it "returns Response with unpopulated combined_data" do
          expect(response.combined_data).to be_empty
        end
    end

  describe "#xml", vcr: "botgarden_taxon_tanacetum" do
    before do
      setup_handler(
        profile: 'botgarden',
        mapper_path: "spec/fixtures/files/mappers/release_6_1/botgarden/"\
          "botgarden_2-0-1_taxon-local.json"
      )
      CollectionSpace::Mapper.config.batch.delimiter = ';'
    end

    let(:data) {
      {"termDisplayName" => "Tanacetum;Tansy", "termStatus" => "made up"}
    }
    let(:response) { described_class.new(data).validate }

    context "when there is a doc", services_call: true do
      it "returns string" do
        resp = handler.process(response).xml
        expect(resp).to be_a(String)
      end
    end

    context "when there is no doc" do
      it "returns nil" do
        resp = response.xml
        expect(resp).to be_nil
      end
    end
  end

  describe '#terms' do
    before do
      setup_handler(
        mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
          "core_6-1-0_collectionobject.json"
      )
      CollectionSpace::Mapper.config.batch.delimiter = '|'
      CollectionSpace::Mapper.config.batch.response_mode = 'termobj'
    end
    let(:processed) do
      resp = described_class.new(data)
      handler.process(resp)
    end

    context "with some terms found and some terms not found" do
      let(:result) { processed.terms.reject{ |t| t.found? } }

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

      resp1 = CollectionSpace::Mapper::Response.new(data1)
      resp2 = CollectionSpace::Mapper::Response.new(data2)

      handler.process(resp1)

      result = handler.process(resp2)
        .terms
        .select { |t| !t.found? }
      expect(result.length).to eq(1)
    end
  end
end

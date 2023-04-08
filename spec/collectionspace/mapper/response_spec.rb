# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Response do
  after{ CollectionSpace::Mapper.reset_config }

  let(:handler) do
    CollectionSpace::Mapper.data_handler
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

    let(:response) { handler.validate(data) }

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
      let(:response) { handler.process(handler.validate(data)) }

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
      context "when response_mode = normal in config" do
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
        let(:response) { handler.process(handler.validate(data)) }
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
    let(:validated) { handler.validate(data) }

    context "when there is a doc", services_call: true do
      it "returns string" do
        response = handler.process(validated).xml
        expect(response).to be_a(String)
      end
    end

    context "when there is no doc" do
      it "returns nil" do
        response = validated.xml
        expect(response).to be_nil
      end
    end
  end
end

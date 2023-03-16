# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataMapper, type: "integration" do
  let(:config) { {delimiter: ";"} }
  let(:mapper) { get_json_record_mapper(mapper_path) }
  let(:handler) do
    CollectionSpace::Mapper::DataHandler.new(
      record_mapper: mapper,
      client: anthro_client,
      cache: anthro_cache,
      csid_cache: anthro_csid_cache,
      config: config
    )
  end
  let(:datahash) { get_datahash(path: datahash_path) }
  let(:prepper) {
    CollectionSpace::Mapper::DataPrepper.new(datahash, handler.searcher,
      handler)
  }
  let(:datamapper) {
    described_class.new(prepper.prep.response, handler, prepper.xphash)
  }
  let(:response) { datamapper.response }
  let(:mapped_doc) { remove_namespaces(response.doc) }
  let(:mapped_xpaths) { list_xpaths(mapped_doc) }
  let(:fixture_doc) { get_xml_fixture(fixture_path) }
  let(:fixture_xpaths) { test_xpaths(fixture_doc, handler.mapper.mappings) }
  let(:diff) { mapped_xpaths - fixture_xpaths }

  context "anthro profile" do
    context "claim record" do
      # Tests for claim record are pending because changes must be made to
      # handling of repeating field groups which contain more than one
      # field which may be populated by multiple authorities.
      # Problem in claimantGroupList
      let(:mapper_path) {
        "spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_claim.json"
      }

      context "record 1" do
        let(:datahash_path) {
          "spec/fixtures/files/datahashes/anthro/claim1.json"
        }
        let(:fixture_path) { "anthro/claim1.xml" }

        it "does not map unexpected fields", skip: "pending bugfix" do
          expect(diff).to eq([])
        end

        it "maps as expected", skip: "pending bugfix" do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context "collectionobject record" do
      let(:mapper_path) {
        "spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_collectionobject.json"
      }

      # record 1 was used for testing default value merging, transformations, etc.
      # we start with record 2 to purely test mapping functionality
      context "record 2" do
        let(:datahash_path) {
          "spec/fixtures/files/datahashes/anthro/collectionobject2.json"
        }
        let(:fixture_path) { "anthro/collectionobject1.xml" }

        it "does not map unexpected fields" do
          expect(diff).to eq([])
        end

        it "maps as expected" do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context "osteology record" do
      let(:mapper_path) {
        "spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_osteology.json"
      }

      context "record 1" do
        let(:datahash_path) {
          "spec/fixtures/files/datahashes/anthro/osteology1.json"
        }
        let(:fixture_path) { "anthro/osteology1.xml" }

        it "does not map unexpected fields" do
          expect(diff).to eq([])
        end

        it "maps as expected" do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataMapper, type: "integration" do
  subject(:datamapper) {
    described_class.new(prepper.prep.response)
  }

  after{ CollectionSpace::Mapper.reset_config }

  let(:datahash) { get_datahash(path: datahash_path) }
  let(:response) { datamapper.response }
  let(:mapped_doc) { remove_namespaces(response.doc) }
  let(:mapped_xpaths) { list_xpaths(mapped_doc) }
  let(:fixture_doc) { get_xml_fixture(fixture_path) }
  let(:fixture_xpaths) do
    test_xpaths(
      fixture_doc,
      CollectionSpace::Mapper.record.mappings
    )
  end
  let(:diff) { mapped_xpaths - fixture_xpaths }

  let(:prepper) {
    CollectionSpace::Mapper.prepper_class.new(datahash)
  }

  context "anthro profile" do
    context "claim record" do
      before do
        setup_handler(
          profile: 'anthro',
          mapper_path: "spec/fixtures/files/mappers/release_6_1/anthro/"\
            "anthro_4-1-2_claim.json"
        )
        CollectionSpace::Mapper.config.batch.delimiter = ';'
      end

      # Tests for claim record are pending because changes must be made to
      # handling of repeating field groups which contain more than one
      # field which may be populated by multiple authorities.
      # Problem in claimantGroupList
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

    context "collectionobject" do
      before do
        setup_handler(
          profile: 'anthro',
          mapper_path: "spec/fixtures/files/mappers/release_6_1/anthro/"\
            "anthro_4-1-2_collectionobject.json"
        )
        CollectionSpace::Mapper.config.batch.delimiter = ';'
      end

      # Record 1 was used for testing default value merging, transformations,
      #   etc. We start with record 2 to purely test mapping functionality
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
      before do
        setup_handler(
          profile: 'anthro',
          mapper_path: "spec/fixtures/files/mappers/release_6_1/anthro/"\
            "anthro_4-1-2_osteology.json"
        )
        CollectionSpace::Mapper.config.batch.delimiter = ';'
      end

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

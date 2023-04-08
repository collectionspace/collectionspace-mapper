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

  context "botgarden profile" do
    context "pottag record" do
      before do
        setup_handler(
          profile: 'botgarden',
          mapper_path: "spec/fixtures/files/mappers/release_7_0/botgarden/"\
            "botgarden_3-0-0_pottag.json"
        )
        CollectionSpace::Mapper.config.batch.delimiter = ';'
      end

      context "record 1" do
        let(:datahash_path) {
          "spec/fixtures/files/datahashes/botgarden/pottag1.json"
        }
        let(:fixture_path) { "botgarden/pottag1.xml" }

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

    context "propagation record" do
      CollectionSpace::Mapper.config.batch.delimiter = ';'
      before do
        setup_handler(
          profile: 'botgarden',
          mapper_path: "spec/fixtures/files/mappers/release_7_0/botgarden/"\
          "botgarden_3-0-0_propagation.json"
        )
      end

      context "record 1" do
        let(:datahash_path) {
          "spec/fixtures/files/datahashes/botgarden/propagation1.json"
        }
        let(:fixture_path) { "botgarden/propagation1.xml" }

        # these tests are waiting for namespace uri fixes in CCU RecordMappers
        it "does not map unexpected fields",
          skip: "something weird going on with fixture_xpaths" do
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

    context "taxon record" do
      before do
        setup_handler(
          profile: 'botgarden',
          mapper_path: "spec/fixtures/files/mappers/release_6_1/botgarden/"\
          "botgarden_2-0-1_taxon-local.json"
        )
        CollectionSpace::Mapper.config.batch.delimiter = ';'
      end

      context "record 1" do
        let(:datahash_path) {
          "spec/fixtures/files/datahashes/botgarden/taxon1.json"
        }
        let(:fixture_path) { "botgarden/taxon1.xml" }
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

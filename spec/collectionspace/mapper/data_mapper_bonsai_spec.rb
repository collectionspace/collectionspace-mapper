# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataMapper, type: "integration" do
  subject(:datamapper) {
    response = prepper.prep.response
    described_class.new(response, response.xphash)
  }

  after{ CollectionSpace::Mapper.reset_config }

  let(:datahash) { get_datahash(path: datahash_path) }
  let(:prepper) { CollectionSpace::Mapper.prepper_class.new(datahash) }
  let(:response) { datamapper.response }
  let(:mapped_doc) { remove_namespaces(response.doc) }
  let(:mapped_xpaths) { list_xpaths(mapped_doc) }
  let(:fixture_doc) { get_xml_fixture(fixture_path) }
  let(:fixture_xpaths) do
    test_xpaths(fixture_doc, CollectionSpace::Mapper.record.mappings)
  end
  let(:diff) { mapped_xpaths - fixture_xpaths }

  context "objectexit record" do
    before do
      setup_handler(
        profile: "bonsai",
        mapper_path: "spec/fixtures/files/mappers/release_6_1/bonsai/"\
          "bonsai_4-1-1_objectexit.json"
      )
      CollectionSpace::Mapper.config.batch.delimiter = ";"
    end

    context "record 1" do
      let(:datahash_path) {
        "spec/fixtures/files/datahashes/bonsai/objectexit1.json"
      }
      let(:fixture_path) { "bonsai/objectexit1.xml" }

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

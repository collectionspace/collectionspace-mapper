# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataMapper, type: "integration" do
  let(:config) { {delimiter: ";"} }
  let(:jsonmapper) { get_json_record_mapper(mapper_path) }
  let(:handler) do
    CollectionSpace::Mapper::DataHandler.new(
      record_mapper: jsonmapper,
      client: bonsai_client,
      cache: bonsai_cache,
      csid_cache: bonsai_csid_cache,
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

  context "bonsai profile" do
    context "objectexit record" do
      let(:mapper_path) {
        "spec/fixtures/files/mappers/release_6_1/bonsai/"\
          "bonsai_4-1-1_objectexit.json"
      }

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
end

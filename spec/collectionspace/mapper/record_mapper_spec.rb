# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::RecordMapper do
  let(:path) {
    "spec/fixtures/files/mappers/release_6_1/anthro/"\
      "anthro_4-1-2_collectionobject.json"
  }
  let(:jsonmapper) { get_json_record_mapper(path) }
  let(:client) { anthro_client }
  let(:mapper) {
    described_class.new(mapper: jsonmapper, csclient: client,
      termcache: anthro_cache)
  }

  it "has expected instance variables" do
    expected = %i[@xpath @config @xml_template @mappings @csclient
      @termcache @csidcache].sort
    expect(mapper.instance_variables.sort).to eq(expected)
  end

  describe "#service_type_extension" do
    context "when initialized with authority mapper" do
      let(:path) {
        "spec/fixtures/files/mappers/release_6_1/anthro/"\
          "anthro_4-1-2_citation-local.json"
      }
      it "returns Authority module name" do
        expect(mapper.service_type_extension).to eq(
          CollectionSpace::Mapper::Authority
        )
      end
    end

    context "when initialized with relationship mapper" do
      let(:path) {
        "spec/fixtures/files/mappers/release_6_1/anthro/"\
          "anthro_4-1-2_authorityhierarchy.json"
      }
      it "returns Relationship module name" do
        expect(mapper.service_type_extension).to eq(
          CollectionSpace::Mapper::Relationship
        )
      end
    end

    context "when initialized with any other mapper" do
      it "returns nil" do
        expect(mapper.service_type_extension).to be_nil
      end
    end
  end
end

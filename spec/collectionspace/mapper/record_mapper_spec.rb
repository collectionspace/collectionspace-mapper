# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::RecordMapper do
  subject(:mapper){ described_class.new(mapper: jsonmapper) }

  before do
    setup(profile: 'anthro')
  end
  after{ CollectionSpace::Mapper.reset_config }

  let(:jsonmapper) { get_json_record_mapper(path) }
  let(:path) {
    "spec/fixtures/files/mappers/release_6_1/anthro/"\
      "anthro_4-1-2_collectionobject.json"
  }

  describe "setting of service_type_extension" do
    let(:result) do
      mapper
      CollectionSpace::Mapper.record.service_type_mixin
    end

    context "when initialized with authority mapper" do
      let(:path) {
        "spec/fixtures/files/mappers/release_6_1/anthro/"\
          "anthro_4-1-2_citation-local.json"
      }
      it "returns Authority module name" do
        expect(result).to eq(
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
        expect(result).to eq(
          CollectionSpace::Mapper::Relationship
        )
      end
    end

    context "when initialized with any other mapper" do
      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end
end

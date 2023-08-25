# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataMapper, type: "integration" do
  include_context "data_mapper"

  let(:profile) { "anthro" }

  context "claim record", vcr: "data_mapper_anthro_claim" do
    let(:mapper) { "anthro_4-1-2_claim" }

    context "record 1" do
      let(:datahash_path) {
        "spec/support/datahashes/anthro/claim1.json"
      }
      let(:fixture_path) { "anthro/claim1.xml" }

      it_behaves_like "Mapped"
    end
  end

  context "collectionobject", vcr: "data_mapper_anthro_collectionobject" do
    let(:mapper) { "anthro_4-1-2_collectionobject" }

    # Record 1 was used for testing default value merging, transformations,
    #   etc. We start with record 2 to purely test mapping functionality
    context "record 2" do
      let(:datahash_path) {
        "spec/support/datahashes/anthro/collectionobject2.json"
      }
      let(:fixture_path) { "anthro/collectionobject1.xml" }

      it_behaves_like "Mapped"
    end
  end

  context "osteology record", vcr: "data_mapper_anthro_osteology" do
    let(:mapper) { "anthro_4-1-2_osteology" }

    context "record 1" do
      let(:datahash_path) {
        "spec/support/datahashes/anthro/osteology1.json"
      }
      let(:fixture_path) { "anthro/osteology1.xml" }

      it_behaves_like "Mapped"
    end
  end
end

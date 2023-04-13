# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataMapper, type: "integration" do
  include_context "data_mapper"

  let(:profile){ "bonsai" }

  context "objectexit record", vcr: "data_mapper_bonsai_objectexit" do
    let(:mapper){ "bonsai_4-1-1_objectexit" }

    context "record 1" do
      let(:datahash_path) {
        "spec/support/datahashes/bonsai/objectexit1.json"
      }
      let(:fixture_path) { "bonsai/objectexit1.xml" }

      it_behaves_like "Mapped"
    end
  end
end

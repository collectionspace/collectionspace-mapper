# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::ObjectHierarchyDataPrepper do
  subject(:prepper){ described_class.new(datahash, handler) }

  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper,
      config: config
    )
  end
  let(:profile){ "core" }
  let(:mapper){ "core_6-1-0_objecthierarchy" }
  let(:config){ {response_mode: "verbose"} }
  let(:datahash){ get_datahash(path: datahash_path) }

  describe "#prep", vcr: "core_domain_check" do
    let(:response){ prepper.prep }

    context "with a missing term", vcr: "core_oh_ids_not_found" do
      let(:datahash_path) {
        "spec/support/datahashes/core/objectHierarchy2.json"
      }

      it "sets response identifier" do
        expect(response.identifier).to eq("2020.1.105 > MISSING")
      end

      it "adds error to response" do
        expect(response.errors.length).to eq(1)
        expect(response.valid?).to be false
      end
    end
  end
end

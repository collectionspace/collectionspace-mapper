# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::NonHierarchicalRelationshipPrepper do
  subject(:prepper){ described_class.new(datahash, handler) }

  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper,
      config: config
    )
  end
  let(:profile){ "core" }
  let(:mapper){ "core_6-1-0_nonhierarchicalrelationship" }
  let(:config){ {response_mode: "verbose"} }
  let(:datahash){ get_datahash(path: datahash_path) }

  describe "#prep", vcr: "core_domain_check" do
    let(:responses){ prepper.prep }

    context "with a missing term", vcr: "core_nhr_ids_not_found" do
      let(:datahash_path) do
        "spec/support/datahashes/core/"\
          "nonHierarchicalRelationship2.json"
      end

      context "with original data" do
        let(:prepped){ responses[0] }

        it "sets response id field as expected" do
          expect(prepped.identifier).to eq(
            "2020.1.107 TEST (collectionobjects) -> LOC MISSING (movements)"
          )
        end

        it "adds error to response" do
          expect(prepped.errors.length).to eq(1)
          expect(prepped.valid?).to be false
        end
      end

      context "with flipped data" do
        let(:prepped){ responses[1] }

        it "sets response id field as expected" do
          expect(prepped.identifier).to eq(
            "LOC MISSING (movements) -> 2020.1.107 TEST (collectionobjects)"
          )
        end

        it "adds error to response" do
          expect(prepped.errors.length).to eq(1)
          expect(prepped.valid?).to be false
        end
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::AuthorityHierarchyPrepper do
  subject(:prepper) { described_class.new(datahash, handler) }

  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper,
      config: config
    )
  end
  let(:profile) { "core" }
  let(:mapper) { "core_6-1-0_authorityhierarchy" }
  let(:config) { {response_mode: "verbose"} }
  let(:datahash) { get_datahash(path: datahash_path) }

  describe "#prep", vcr: "core_domain_check" do
    let(:response) { prepper.prep }

    vcr_opts = {
      cassette_name: "core_concept_cats_tuxedo",
      record: :new_episodes
    }
    context "with a missing term", vcr: vcr_opts do
      let(:datahash_path) do
        "spec/support/datahashes/core/authorityHierarchy2.json"
      end

      it "sets response identifier" do
        expect(response.identifier).to eq("Cats > Tuxedo cats")
      end

      it "adds error to response" do
        expect(response.errors.length).to eq(1)
        expect(response.valid?).to be false
      end

      context "with single record type handler" do
        let(:handler) do
          setup_single_record_type_handler(
            mapper: "https://raw.githubusercontent.com/collectionspace/"\
              "cspace-config-untangler/refs/heads/main/data/mappers/"\
              "community_profiles/release_8_1_1/core/"\
              "core_10-0-2_authorityhierarchy.json",
            config: config
          )
        end

        it "sets response identifier" do
          expect(response.identifier).to eq("Cats > Tuxedo cats")
        end

        it "adds error to response" do
          expect(response.errors.length).to eq(1)
          expect(response.valid?).to be false
        end
      end
    end
  end
end

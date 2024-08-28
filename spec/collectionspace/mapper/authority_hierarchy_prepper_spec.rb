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

    context "with a missing term", vcr: "core_concept_cats_tuxedo" do
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
    end

    context "with record_matchpoint = uri and no missing terms",
      vcr: "core_concept_cats_siamese" do
      let(:datahash_path) do
        "spec/support/datahashes/core/authorityHierarchy1.json"
      end
      let(:config) do
        {
          response_mode: "verbose",
          record_matchpoint: "uri"
        }
      end

      it "sets response identifier" do
        expect(response.identifier).to eq("Cats > Siamese cats")
        expect(response.valid?).to be true
        expect(response.uri).to be nil
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::AuthorityPrepper do
  subject(:prepper) { described_class.new(datahash, handler) }

  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper,
      config: config
    )
  end
  let(:profile) { "lhmc" }
  let(:mapper) { "lhmc_3-1-1_person-local" }
  let(:config) { {response_mode: "verbose"} }
  let(:datahash) { {"termDisplayName" => "Xanadu", "placeNote" => "note"} }

  describe "#prep", vcr: "lhmc_domain_check" do
    let(:response) { prepper.prep }

    it "sets response identifier" do
      expect(response.identifier).to eq("Xanadu2760257775")
    end

    it "adds shortIdentifer to transformed data" do
      expect(response.transformed_data.key?("shortidentifier")).to be true
      expect(response.transformed_data["shortidentifier"]).to eq(
        ["Xanadu2760257775"]
      )
    end
  end
end

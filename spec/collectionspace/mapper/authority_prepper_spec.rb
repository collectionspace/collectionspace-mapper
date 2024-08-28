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

  describe "#prep", vcr: "lhmc_domain_check" do
    let(:response) { prepper.prep }

    context "with record_matchpoint = identifier" do
      let(:config) do
        {response_mode: "verbose", record_matchpoint: "identifier"}
      end
      let(:datahash) { {"termDisplayName" => "Xanadu", "placeNote" => "note"} }

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

    context "with record_matchpoint = uri" do
      let(:config) { {response_mode: "verbose", record_matchpoint: "uri"} }
      let(:datahash) do
        {"uri" =>
         "/personauthorities/896d2991-a9ff-4ba2-80bf/items"\
         "/87b0e4c6-3360-4a95-9c07",
         "termDisplayName" => "Xanadu", "placeNote" => "note"}
      end

      it "sets response identifier and uri" do
        expect(response.identifier).to eq("Xanadu2760257775")
        expect(response.uri).to eq("/personauthorities/896d2991-a9ff-4ba2-80bf"\
                                   "/items/87b0e4c6-3360-4a95-9c07")
      end

      it "adds shortIdentifer to transformed data" do
        expect(response.transformed_data.key?("shortidentifier")).to be true
        expect(response.transformed_data["shortidentifier"]).to eq(
          ["Xanadu2760257775"]
        )
      end
    end
  end
end

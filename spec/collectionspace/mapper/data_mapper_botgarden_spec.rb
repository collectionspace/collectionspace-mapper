# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataMapper, type: "integration" do
  include_context "data_mapper"

  let(:profile){ "botgarden" }

  context "pottag record", vcr: "data_mapper_botgarden_pottag" do
    let(:mapper){ "botgarden_3-0-2_pottag" }

    context "record 1" do
      let(:datahash_path) {
        "spec/support/datahashes/botgarden/pottag1.json"
      }
      let(:fixture_path) { "botgarden/pottag1.xml" }

      it_behaves_like "Mapped"
    end
  end

  context "propagation record", vcr: "data_mapper_botgarden_propagation" do
    let(:mapper){ "botgarden_3-0-2_propagation" }

    context "record 1" do
      let(:datahash_path) {
        "spec/support/datahashes/botgarden/propagation1.json"
      }
      let(:fixture_path) { "botgarden/propagation1.xml" }

      # these tests are waiting for namespace uri fixes in CCU RecordMappers
      it_behaves_like "Mapped"
    end
  end

  context "taxon record", vcr: "data_mapper_botgarden_taxon" do
#    skip: "multiauthority field groups" do
    let(:mapper){ "botgarden_3-0-2_taxon-local" }
    let(:customcfg){ {response_mode: "verbose"} }

    context "record 1" do
      let(:datahash_path) {
        "spec/support/datahashes/botgarden/taxon1.json"
      }
      let(:fixture_path) { "botgarden/taxon_new.xml" }

      it_behaves_like "Mapped"
    end
  end
end

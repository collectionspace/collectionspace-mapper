# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Tools::RecordStatusServiceBuilder do
  subject(:builder) { handler.status_checker }

  let(:handler) do
    setup_handler(
      mapper: "core_6-1-0_group",
      config: config
    )
  end
  let(:config) { {} }

  context "when status_check_method = client", vcr: "core_domain_check" do
    let(:config) { {status_check_method: "client"} }

    describe ".call" do
      it "returns RecordStatusServiceClient" do
        expect(builder).to be_a(
          CollectionSpace::Mapper::Tools::RecordStatusServiceClient
        )
      end

      context "and when record_matchpoint = uri" do
        let(:config) do
          {status_check_method: "client", record_matchpoint: "uri"}
        end

        it "returns RecordStatusServiceClient" do
          expect(builder).to be_a(
            CollectionSpace::Mapper::Tools::RecordStatusServiceClientUri
          )
        end
      end
    end

    context "when status_check_method = cache" do
      let(:config) { {status_check_method: "cache"} }

      it "raises returns RecordStatusServiceCache" do
        expect(builder).to be_a(
          CollectionSpace::Mapper::Tools::RecordStatusServiceCache
        )
      end

      context "and when record_matchpoint = uri" do
        let(:config) do
          {status_check_method: "cache", record_matchpoint: "uri"}
        end
      end
    end
  end
end

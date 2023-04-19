# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Tools::RecordStatusServiceBuilder do
  subject(:builder){ handler.status_checker }

  let(:handler) do
    setup_handler(
      mapper: "core_6-1-0_group",
      config: config
    )
  end
  let(:config){ {} }

  describe ".call", vcr: "core_domain_check" do
    it "returns RecordStatusServiceClient" do
      expect(builder).to be_a(
        CollectionSpace::Mapper::Tools::RecordStatusServiceClient
      )
    end

    context "when status_check_method = cache" do
      let(:config){ {status_check_method: "cache"} }

      it "raises returns RecordStatusServiceCache" do
        expect(builder).to be_a(
          CollectionSpace::Mapper::Tools::RecordStatusServiceCache
        )
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Tools::RecordStatusServiceBuilder do
  subject(:builder) { described_class }

  after{ CollectionSpace::Mapper.reset_config }

  describe ".call" do
    let(:result){ builder.call }

    context "when status_check_method = client" do
      before do
        setup(
          mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
            "core_6-1-0_group.json"
        )
      end

      it "raises returns RecordStatusServiceClient" do
        expect(result).to be_a(
          CollectionSpace::Mapper::Tools::RecordStatusServiceClient
        )
      end
    end

    context "when status_check_method = cache" do
      before do
        setup(
          mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
            "core_6-1-0_group.json"
        )
        CollectionSpace::Mapper.config.batch.status_check_method = "cache"
      end

      it "raises returns RecordStatusServiceCache" do
        expect(result).to be_a(
          CollectionSpace::Mapper::Tools::RecordStatusServiceCache
        )
      end
    end
  end
end

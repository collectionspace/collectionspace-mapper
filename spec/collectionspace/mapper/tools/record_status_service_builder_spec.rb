# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Tools::RecordStatusServiceBuilder do
  subject(:builder) { described_class }
  let(:client) { core_client }
  let(:config) { {} }

  describe ".call" do
    let(:mapper) do
      CollectionSpace::Mapper::RecordMapper.new(mapper: get_json_record_mapper(
        "spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_group.json"
      ), termcache: core_cache, csidcache: "foo", batchconfig: config)
    end

    context "when status_check_method = client" do
      let(:config) { {status_check_method: "client"} }

      it "raises returns RecordStatusServiceClient" do
        expect(builder.call(mapper: mapper, client: client)).to be_a(
          CollectionSpace::Mapper::Tools::RecordStatusServiceClient
        )
      end
    end

    context "when status_check_method = cache" do
      let(:config) { {status_check_method: "cache"} }

      it "raises returns RecordStatusServiceCache" do
        expect(builder.call(mapper: mapper)).to be_a(
          CollectionSpace::Mapper::Tools::RecordStatusServiceCache
        )
      end
    end
  end
end

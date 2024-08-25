# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::HandlerFullRecord do
  subject(:handler) do
    described_class.new(record_mapper: mapper, client: client, cache: cache,
      csid_cache: csidcache, config: config)
  end

  let(:mapper) { get_json_record_mapper("core_6-1-0_collectionobject") }
  let(:client) { core_client }
  let(:cache) { core_cache }
  let(:csidcache) { core_csid_cache }
  let(:config) { {} }

  describe "#check_fields", vcr: "core_domain_check" do
    let(:result) { handler.check_fields(data) }

    context "with :uri field" do
      let(:data) do
        {"objectnumber" => "1", "uri" => "foo", "briefdescription" => "bar"}
      end

      context "when record_matchpoint == identifier" do
        let(:config) { {"record_matchpoint" => "identifier"} }

        it "reports uri as unknown field" do
          expect(result[:unknown_fields]).to include("uri")
        end
      end

      context "when record_matchpoint == uri" do
        let(:config) { {"record_matchpoint" => "uri"} }

        it "reports uri as unknown field" do
          expect(result[:unknown_fields]).to be_empty
        end
      end
    end
  end
end

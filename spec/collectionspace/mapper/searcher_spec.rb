# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Searcher do
  let(:client) { core_client }
  let(:config) { CollectionSpace::Mapper::Config.new(config: config_hash) }
  let(:klass) { described_class.new(client: client, config: config) }

  describe "#.call" do
    let(:args) { {value: "All", type: "vocabularies", subtype: "publishto"} }
    let(:result) { klass.call(**args) }

    context "when search_if_not_cached = true" do
      let(:config_hash) { {} }
      it "returns expected hash" do
        expected = {
          "fieldsReturned" => "csid|uri|refName|updatedAt|workflowState|rev|sourcePage|sas|proposed|referenced|deprecated|termStatus|description|source|order|displayName|shortIdentifier", "itemsInPage" => "1", "list_item" => {
            "csid" => "d614ebc5-96fd-4680-9727", "displayName" => "All", "proposed" => "true", "refName" => "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(all)'All'", "rev" => "0", "sas" => "false", "shortIdentifier" => "all", "updatedAt" => "2020-02-08T03:30:26.054Z", "uri" => "/vocabularies/e2ea6ca3-4c60-427d-96e5/items/d614ebc5-96fd-4680-9727", "workflowState" => "project"
          }, "pageNum" => "0", "pageSize" => "25", "totalItems" => "1"
        }
        expect(result).to eq(expected)
      end
    end

    context "when search_if_not_cached = false" do
      let(:config_hash) { {search_if_not_cached: false} }

      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end
end

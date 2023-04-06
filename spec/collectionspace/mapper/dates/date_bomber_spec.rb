# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Dates::DateBomber do
  subject(:creator) { described_class.new }
  let(:client) { anthro_client }
  let(:cache) { anthro_cache }
  let(:csid_cache) { anthro_csid_cache }
  let(:config) { CollectionSpace::Mapper::Config.new }
  let(:searcher) do
    CollectionSpace::Mapper::Searcher.new(client: client, config: config)
  end
  let(:handler) do
    CollectionSpace::Mapper::Dates::StructuredDateHandler.new(
      client: client,
      cache: cache,
      csid_cache: csid_cache,
      config: config,
      searcher: searcher
    )
  end

  describe "#mappable" do
    let(:result) { creator.mappable }

    it "returns expected" do
      expected = CollectionSpace::Mapper.bomb
      expect(result["dateEarliestScalarValue"]).to eq(expected)
    end
  end

  describe "#stamp" do
    let(:result) { creator.stamp }

    it "returns expected" do
      expected = CollectionSpace::Mapper.bomb
      expect(result).to eq(expected)
    end
  end
end

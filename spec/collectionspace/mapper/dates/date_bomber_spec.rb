# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Dates::DateBomber do
  subject(:bomber) { described_class.new }

  describe "#mappable" do
    let(:result) { bomber.mappable }

    it "returns expected" do
      expected = CollectionSpace::Mapper.bomb
      expect(result["dateEarliestScalarValue"]).to eq(expected)
    end
  end

  describe "#stamp" do
    let(:result) { bomber.stamp }

    it "returns expected" do
      expected = CollectionSpace::Mapper.bomb
      expect(result).to eq(expected)
    end
  end
end

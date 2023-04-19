# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Dates::NullDate do
  subject(:creator){ described_class.new }

  describe "#mappable" do
    let(:result){ creator.mappable }

    it "returns expected" do
      expect(result).to eq({})
    end
  end

  describe "#stamp" do
    let(:result){ creator.stamp }

    it "returns expected" do
      expect(result).to eq("")
    end
  end
end

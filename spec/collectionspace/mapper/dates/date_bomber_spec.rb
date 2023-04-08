# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Dates::DateBomber do
  subject(:creator) { described_class.new }
  before do
    setup_handler(
      profile: 'anthro',
      mapper_path: "spec/fixtures/files/mappers/release_6_1/anthro/"\
        "anthro_4-1-2_collectionobject.json"
    )
    CollectionSpace::Mapper.config.batch.delimiter = ';'
  end
  after{ CollectionSpace::Mapper.reset_config }

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

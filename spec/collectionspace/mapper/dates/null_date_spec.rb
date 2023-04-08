# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Dates::NullDate do
  subject(:creator) { described_class.new }

  before do
    setup_handler(
      profile: 'anthro',
      mapper_path: "spec/fixtures/files/mappers/release_6_1/anthro/"\
        "anthro_4-1-2_collectionobject.json"
    )
  end
  after{ CollectionSpace::Mapper.reset_config }

  describe "#mappable" do
    let(:result) { creator.mappable }

    it "returns expected" do
      expect(result).to eq({})
    end
  end

  describe "#stamp" do
    let(:result) { creator.stamp }

    it "returns expected" do
      expect(result).to eq("")
    end
  end
end

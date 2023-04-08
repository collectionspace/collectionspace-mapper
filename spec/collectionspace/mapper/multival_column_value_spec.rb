# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::MultivalColumnValue do
    let(:colval) do
    described_class.new(
      column: colname,
      value: colvalue,
      mapping: mapping)
  end

  before do
    CollectionSpace::Mapper.config.batch.delimiter = "|"
    CollectionSpace::Mapper.config.batch.subgroup_delimiter = "^^"
    setup_handler(
      mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
      "core_6-1-0_collectionobject.json"
    )
  end
  after{ CollectionSpace::Mapper.reset_config }

  let(:mapping) { CollectionSpace::Mapper.record.mappings.lookup(colname) }

  describe "#split" do
    let(:colname) { "collection" }
    let(:colvalue) { "blah| blah" }
    it "returns value as stripped element(s) in Array" do
      expect(colval.split).to eq(%w[blah blah])
    end
  end
end

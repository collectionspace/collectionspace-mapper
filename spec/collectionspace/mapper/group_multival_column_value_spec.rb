# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::GroupMultivalColumnValue do
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
      profile: "bonsai",
      mapper_path: "spec/fixtures/files/mappers/release_6_1/bonsai/"\
        "bonsai_4-1-1_conservation.json"
    )
  end
  after{ CollectionSpace::Mapper.reset_config }

  let(:mapping) { CollectionSpace::Mapper.record.mappings.lookup(colname) }

  describe "#split" do
    let(:colname) { "fertilizerToBeUsed" }
    let(:colvalue) { "a|b^^c" }
    it "returns value(s) as Hash where group occurrences are the keys" do
      expected = {1 => ["a"],
                  2 => %w[b c]}
      expect(colval.split).to eq(expected)
    end
  end
end

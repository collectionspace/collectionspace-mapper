# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::SimpleSplitter do
  before(:all) do
    CollectionSpace::Mapper.config.batch.delimiter = ";"
    CollectionSpace::Mapper.config.batch.subgroup_delimiter = "^^"
  end
  after(:all){ CollectionSpace::Mapper.reset_config }

  describe "#result" do
    context 'when "a"' do
      it 'returns ["a"]' do
        s = CollectionSpace::Mapper::SimpleSplitter.new("a")
        expect(s.result).to eq(%w[a])
      end
    end
    context 'when " a"' do
      it 'returns ["a"]' do
        s = CollectionSpace::Mapper::SimpleSplitter.new(" a")
        expect(s.result).to eq(%w[a])
      end
    end
    context 'when "a;b;c"' do
      it 'returns ["a", "b", "c"]' do
        s = CollectionSpace::Mapper::SimpleSplitter.new("a;b;c")
        expect(s.result).to eq(%w[a b c])
      end
    end
    context 'when ";b;c"' do
      it 'returns ["", "b", "c"]' do
        s = CollectionSpace::Mapper::SimpleSplitter.new(";b;c")
        expect(s.result).to eq(["", "b", "c"])
      end
    end
    context 'when "a;b;"' do
      it 'returns ["a", "b", ""]' do
        s = CollectionSpace::Mapper::SimpleSplitter.new("a;b;")
        expect(s.result).to eq(["a", "b", ""])
      end
    end
    context 'when "a;;c"' do
      it 'returns ["a", "", "c"]' do
        s = CollectionSpace::Mapper::SimpleSplitter.new("a;;c")
        expect(s.result).to eq(["a", "", "c"])
      end
    end
  end
end

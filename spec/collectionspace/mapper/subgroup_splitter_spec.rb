# frozen_string_literal: true

RSpec.describe CollectionSpace::Mapper::SubgroupSplitter do
  before(:all) do
    CollectionSpace::Mapper.config.batch.delimiter = ";"
    CollectionSpace::Mapper.config.batch.subgroup_delimiter = "^^"
  end
  after(:all){ CollectionSpace::Mapper.reset_config }

  describe "#result" do
    context 'when "a^^b;c^^d"' do
      it 'returns [["a", "b"], ["c", "d"]]' do
        s = CollectionSpace::Mapper::SubgroupSplitter.new("a^^b;c^^d")
        expect(s.result).to eq([%w[a b], %w[c d]])
      end
    end
    context 'when "a;c"' do
      it 'returns [["a"], ["c"]]' do
        s = CollectionSpace::Mapper::SubgroupSplitter.new("a;c")
        expect(s.result).to eq([%w[a], %w[c]])
      end
    end
    context 'when "a;c^^d"' do
      it 'returns [["a"], ["c", "d"]]' do
        s = CollectionSpace::Mapper::SubgroupSplitter.new("a;c^^d")
        expect(s.result).to eq([%w[a], %w[c d]])
      end
    end
    context 'when "a^^;c^^d"' do
      it 'returns [["a", ""], ["c", "d"]]' do
        s = CollectionSpace::Mapper::SubgroupSplitter.new("a^^;c^^d")
        expect(s.result).to eq([["a", ""], %w[c d]])
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::SimpleSplitter do
  before(:all) do
    @config = CS::Mapper::Config.new(config: {delimiter: ';', subgroup_delimiter: '^^'})
  end

  describe '#result' do
    context 'when "a"' do
      it 'returns ["a"]' do
        s = CollectionSpace::Mapper::SimpleSplitter.new('a', @config)
        expect(s.result).to eq(%w[a])
      end
    end
    context 'when " a"' do
      it 'returns ["a"]' do
        s = CollectionSpace::Mapper::SimpleSplitter.new(' a', @config)
        expect(s.result).to eq(%w[a])
      end
    end
    context 'when "a;b;c"' do
      it 'returns ["a", "b", "c"]' do
        s = CollectionSpace::Mapper::SimpleSplitter.new('a;b;c', @config)
        expect(s.result).to eq(%w[a b c])
      end
    end
    context 'when ";b;c"' do
      it 'returns ["", "b", "c"]' do
        s = CollectionSpace::Mapper::SimpleSplitter.new(';b;c', @config)
        expect(s.result).to eq(['', 'b', 'c'])
      end
    end
    context 'when "a;b;"' do
      it 'returns ["a", "b", ""]' do
        s = CollectionSpace::Mapper::SimpleSplitter.new('a;b;', @config)
        expect(s.result).to eq(['a', 'b', ''])
      end
    end
    context 'when "a;;c"' do
      it 'returns ["a", "", "c"]' do
        s = CollectionSpace::Mapper::SimpleSplitter.new('a;;c', @config)
        expect(s.result).to eq(['a', '', 'c'])
      end
    end
  end
end

RSpec.describe CollectionSpace::Mapper::SubgroupSplitter do
  before(:all) do
    @config = CS::Mapper::Config.new(config: {delimiter: ';', subgroup_delimiter: '^^'})
  end

  describe '#result' do
    context 'when "a^^b;c^^d"' do
      it 'returns [["a", "b"], ["c", "d"]]' do
        s = CollectionSpace::Mapper::SubgroupSplitter.new('a^^b;c^^d', @config)
        expect(s.result).to eq([%w[a b], %w[c d]])
      end
    end
    context 'when "a;c"' do
      it 'returns [["a"], ["c"]]' do
        s = CollectionSpace::Mapper::SubgroupSplitter.new('a;c', @config)
        expect(s.result).to eq([%w[a], %w[c]])
      end
    end
    context 'when "a;c^^d"' do
      it 'returns [["a"], ["c", "d"]]' do
        s = CollectionSpace::Mapper::SubgroupSplitter.new('a;c^^d', @config)
        expect(s.result).to eq([%w[a], %w[c d]])
      end
    end
    context 'when "a^^;c^^d"' do
      it 'returns [["a", ""], ["c", "d"]]' do
        s = CollectionSpace::Mapper::SubgroupSplitter.new('a^^;c^^d', @config)
        expect(s.result).to eq([['a', ''], %w[c d]])
      end
    end
  end
end

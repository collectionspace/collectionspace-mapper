# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::SimpleSplitter do
  before(:all) do
    Mapper.const_set('CONFIG', { delimiter: ';', subgroup_delimiter: '^^' })
  end
  
  describe '#result' do
    context 'when "a"' do
      it 'returns ["a"]' do
        s = SimpleSplitter.new('a')
        expect(s.result).to eq(%w[a])
      end
    end
    context 'when " a"' do
      it 'returns ["a"]' do
        s = SimpleSplitter.new(' a')
        expect(s.result).to eq(%w[a])
      end
    end
    context 'when "a;b;c"' do
      it 'returns ["a", "b", "c"]' do
        s = SimpleSplitter.new('a;b;c')
        expect(s.result).to eq(%w[a b c])
      end
    end
    context 'when ";b;c"' do
      it 'returns ["", "b", "c"]' do
        s = SimpleSplitter.new(';b;c')
        expect(s.result).to eq(['', 'b', 'c'])
      end
    end
    context 'when "a;b;"' do
      it 'returns ["a", "b", ""]' do
        s = SimpleSplitter.new('a;b;')
        expect(s.result).to eq(['a', 'b', ''])
      end
    end
    context 'when "a;;c"' do
      it 'returns ["a", "", "c"]' do
        s = SimpleSplitter.new('a;;c')
        expect(s.result).to eq(['a', '', 'c'])
      end
    end
  end
end

RSpec.describe CollectionSpace::Mapper::SubgroupSplitter do
   before(:all) do
    Mapper.const_set('CONFIG', { delimiter: ';', subgroup_delimiter: '^^' })
  end

   describe '#result' do
    context 'when "a^^b;c^^d"' do
      it 'returns [["a", "b"], ["c", "d"]]' do
        s = SubgroupSplitter.new('a^^b;c^^d')
        expect(s.result).to eq([%w[a b], %w[c d]])
      end
    end
    context 'when "a;c"' do
      it 'returns [["a"], ["c"]]' do
        s = SubgroupSplitter.new('a;c')
        expect(s.result).to eq([%w[a], %w[c]])
      end
    end
    context 'when "a;c^^d"' do
      it 'returns [["a"], ["c", "d"]]' do
        s = SubgroupSplitter.new('a;c^^d')
        expect(s.result).to eq([%w[a], %w[c d]])
      end
    end
    context 'when "a^^;c^^d"' do
      it 'returns [["a", ""], ["c", "d"]]' do
        s = SubgroupSplitter.new('a^^;c^^d')
        expect(s.result).to eq([['a', ''], %w[c d]])
      end
    end
  end
end

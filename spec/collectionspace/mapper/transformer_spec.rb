# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Transformer do
  let(:client){ anthro_client }
  let(:cache){ anthro_cache }
  let(:mapperpath){ 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_collectionobject_transforms.json' }
  let(:recmapper) do
    CS::Mapper::RecordMapper.new(mapper: File.read(mapperpath),
                                 csclient: client,
                                 termcache: cache)
  end

  describe '.create' do
    let(:creator) do
      described_class.create(recmapper: recmapper,
                             type: type,
                             transform: transform)
    end

    context 'given an authority transform' do
      let(:type){ :authority }
      let(:transform){ %w[personauthorities person] }

      it 'returns an AuthorityTransformer' do
        expect(creator).to be_a(CS::Mapper::AuthorityTransformer)
      end
    end

    context 'given a vocabulary transform' do
      let(:type){ :vocabulary }
      let(:transform){ 'behrensmeyer' }
      it 'returns a VocabularyTransformer' do
        expect(creator).to be_a(CS::Mapper::VocabularyTransformer)
      end
    end

    context 'given special transforms' do
      let(:type){ :special }
      let(:transform){ %w[downcase_value boolean behrensmeyer_translate] }
      it 'returns array of expected transformers' do
        expected = [CS::Mapper::DowncaseTransformer, CS::Mapper::BooleanTransformer,
                    CS::Mapper::BehrensmeyerTransformer]
        expect(creator.map(&:class)).to eq(expected)
      end
    end

    context 'given replacement transforms' do
      let(:type){ :replacements }
      let(:transform){ [{find: ' ', replace: '-', type: 'plain'}] }
      it 'returns a FindReplaceTransformer' do
        expect(creator).to be_a(CS::Mapper::FindReplaceTransformer)
      end
    end
  end
end

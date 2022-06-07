# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Transformers do
  let(:client){ anthro_client }
  let(:cache){ anthro_cache }
  let(:mapperpath){ 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_collectionobject_transforms.json' }
  let(:recmapper) do
    CollectionSpace::Mapper::RecordMapper.new(mapper: File.read(mapperpath),
                                 csclient: client,
                                 termcache: cache)
  end
  let(:mapping){ recmapper.mappings.lookup(colname) }
  let(:xforms) do
    described_class.new(colmapping: mapping,
                        transforms: mapping.transforms,
                        recmapper: recmapper)
  end

  describe '#queue' do
    context 'when measuredByPerson column' do
      let(:colname){ 'measuredByPerson' }
      it 'contains only AuthorityTransformer' do
        expect(xforms.queue.map(&:class)).to eq([CollectionSpace::Mapper::AuthorityTransformer])
      end
    end

    context 'when behrensmeyerSingleLower column' do
      let(:colname){ 'behrensmeyerSingleLower' }
      # let(:result) { xforms.queue }
      let(:result){ xforms.queue.map(&:class) }
      it 'expected elements are in expected order' do
        expect(result).to eq([CollectionSpace::Mapper::BehrensmeyerTransformer, CollectionSpace::Mapper::VocabularyTransformer])
      end
    end
  end
end

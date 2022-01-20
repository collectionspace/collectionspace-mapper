# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::ColumnValue do
  let(:mapperpath){ 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_collectionobject.json'}
  let(:recmapper){ get_record_mapper_object(mapperpath, core_cache) }
  let(:mapping){ recmapper.mappings.lookup(colname) }
  let(:colval) do described_class.new(column: colname,
                                      value: colvalue,
                                      recmapper: recmapper,
                                      mapping: mapping) end

  describe '.create' do
    let(:creator) do described_class.create(column: colname,
                                            value: colvalue,
                                            recmapper: recmapper,
                                            mapping: mapping) end

    context 'given core collectionobject collection value' do
      let(:colname){ 'collection' }
      let(:colvalue){ 'blah' }
      it 'returns ColumnValue' do
        expect(creator).to be_a(CS::Mapper::ColumnValue)
      end
    end

    context 'given core collectionobject comment value' do
      let(:colname){ 'comment' }
      let(:colvalue){ 'blah' }
      it 'returns MultivalColumnValue' do
        expect(creator).to be_a(CS::Mapper::MultivalColumnValue)
      end
    end

    context 'given core collectionobject comment value' do
      let(:colname){ 'title' }
      let(:colvalue){ 'blah' }
      it 'returns GroupColumnValue' do
        expect(creator).to be_a(CS::Mapper::GroupColumnValue)
      end
    end

    context 'given bonsai conservation fertilizerToBeUsed value' do
      let(:mapperpath){ 'spec/fixtures/files/mappers/release_6_1/bonsai/bonsai_4-1-1_conservation.json' }
      let(:colname){ 'fertilizerToBeUsed' }
      let(:colvalue){ 'blah' }
      it 'returns GroupMultivalColumnValue' do
        expect(creator).to be_a(CS::Mapper::GroupMultivalColumnValue)
      end
    end

    context 'given core collectionobject titleTranslation value' do
      let(:colname){ 'titleTranslation' }
      let(:colvalue){ 'blah' }
      it 'returns SubgroupColumnValue' do
        expect(creator).to be_a(CS::Mapper::SubgroupColumnValue)
      end
    end
  end

  describe '#split' do
    let(:colname){ 'collection' }
    let(:colvalue){ 'blah ' }
    it 'returns value as stripped single element in Array' do
      expect(colval.split).to eq(['blah'])
    end
  end
end


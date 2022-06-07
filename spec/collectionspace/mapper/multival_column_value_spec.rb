# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::MultivalColumnValue do
  let(:mapperpath){ 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_collectionobject.json' }
  let(:config){ {delimiter: '|', subgroup_delimiter: '^^'} }
  let(:recmapper) do
    CollectionSpace::Mapper::RecordMapper.new(mapper: get_json_record_mapper(mapperpath),
                                 batchconfig: config,
                                 termcache: core_cache)
  end
  let(:mapping){ recmapper.mappings.lookup(colname) }
  let(:colval) do
    described_class.new(column: colname,
                        value: colvalue,
                        recmapper: recmapper,
                        mapping: mapping)
  end

  describe '#split' do
    let(:colname){ 'collection' }
    let(:colvalue){ 'blah| blah' }
    it 'returns value as stripped element(s) in Array' do
      expect(colval.split).to eq(%w[blah blah])
    end
  end
end

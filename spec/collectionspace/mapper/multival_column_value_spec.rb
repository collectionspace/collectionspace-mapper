# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::MultivalColumnValue do
  let(:mapperpath) { 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_collectionobject.json' }
  let(:config) { {delimiter: '|', subgroup_delimiter: '^^'} } 
  let(:recmapper) { CS::Mapper::RecordMapper.new(mapper: get_json_record_mapper(mapperpath),
                                                 batchconfig: config) }
  let(:mapping) { recmapper.mappings.lookup(colname) }
  let(:colval) { described_class.new(column: colname,
                                     value: colvalue,
                                     recmapper: recmapper,
                                     mapping: mapping) }

  describe '#split' do
    let(:colname) { 'collection' }
    let(:colvalue) { 'blah| blah' }
    it 'returns value as stripped element(s) in Array' do
      expect(colval.split).to eq(['blah', 'blah'])
    end
  end
end


# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataValidator do
  before(:all) do
    @rm_anthro_co = get_json_record_mapper(path: 'spec/fixtures/files/mappers/anthro_4_0_0-collectionobject.json')
    @dv = DataValidator.new(record_mapper: @rm_anthro_co, cache: anthro_cache)
  end
  
  it 'gets downcased list of required fields' do
    expect(@dv.required_fields).to eq(['objectnumber'])
  end
  
  context 'when required field present' do
    context 'and required field populated' do
      it 'no required field error returned' do
        data = { 'objectNumber' => '123' }
        v = @dv.validate(data)
        err = v.select{ |errhash| errhash[:type] == 'required fields' }
        expect(err.size).to eq(0)
      end
    end

    context 'and required field present but empty' do
      it 'required field error returned with message "required field is empty"' do
        data = { 'objectNumber' => '' }
        v = @dv.validate(data)
        err = v.select{ |errhash| errhash[:message] == 'required field is empty' }
        expect(err.size).to eq(1)
      end
    end
  end

  context 'when required field not present in data' do
    it 'required field error returned with message "required field missing"' do
      data = { 'randomField' => 'random value' }
      v = @dv.validate(data)
      err = v.select{ |errhash| errhash[:message] == 'required field missing' }
      expect(err.size).to eq(1)
    end
  end
end


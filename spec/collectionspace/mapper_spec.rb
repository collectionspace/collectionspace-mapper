# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper do
  let(:rc) { anthro_cache }
  
  it 'has a version number' do
    expect(CollectionSpace::Mapper::VERSION).not_to be nil
  end

  it 'can create anthro refcache' do
    expect(rc).to be_a(CollectionSpace::RefCache)  
  end

  context 'when reading in JSON RecordMapper file' do
    it 'returns a Hash' do
      path = 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4_1_0-collectionobject.json'
      h = get_json_record_mapper(path: path)
      expect(h).to be_a(Hash)
    end
  end

  describe '#setup_data' do
    context 'when passed a Mapper::Response' do
      it 'returns that Response' do
        response = Response.new({ 'objectNumber'=>'123' })
        expect(Mapper::setup_data(response)).to eq(response)
      end
    end
    context 'when passed a Hash' do
      before(:all) do
        @data = { 'objectNumber'=>'123' }
        @response = Mapper::setup_data(@data)
      end
      it 'returns a Mapper::Response' do
        expect(@response).to be_a(Mapper::Response)
      end
      it 'sets Hash as Response.orig_data' do
        expect(@response.orig_data).to eq(@data)
      end
    end
    context 'when passed other class of object' do
      before(:all) do
        @data = ['objectNumber', '123']
        @response = Mapper::setup_data(@data)
      end
      it 'returns a Mapper::Response' do
        expect(@response).to be_a(Mapper::Response)
      end
      it 'sets data passed as Response.orig_data' do
        expect(@response.orig_data).to eq(@data)
      end
      it 'writes error to Response.errors' do
        expect(@response.errors.length).to eq(1)
      end
    end
  end
end

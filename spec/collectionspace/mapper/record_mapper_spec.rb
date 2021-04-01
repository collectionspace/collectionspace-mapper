# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::RecordMapper do
  
  let(:mapper) { described_class.new(get_json_record_mapper(path)) }
  let(:path) { 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_collectionobject.json' }

  it 'has expected instance variables' do
    expected = [:@xpath, :@config, :@xml_template, :@mappings, :@batchconfig].sort
    expect(mapper.instance_variables.sort).to eq(expected)
  end

  describe '#service_type' do
    context 'when initialized with authority mapper' do
      let(:path) { 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_citation-local.json' }
      it 'returns Authority module name' do
        expect(mapper.service_type).to eq(CS::Mapper::Authority)
      end
    end

    context 'when initialized with relationship mapper' do
      let(:path) { 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_authorityhierarchy.json' }
      it 'returns Relationship module name' do
        expect(mapper.service_type).to eq(CS::Mapper::Relationship)
      end
    end

    context 'when initialized with any other mapper' do
      it 'returns nil' do
        expect(mapper.service_type).to be_nil
      end
    end
  end
end

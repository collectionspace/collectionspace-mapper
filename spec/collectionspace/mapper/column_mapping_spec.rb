# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::ColumnMapping do

  # all mapping hash keys from Untangler
  #      :fieldname=>"numberValue",
  #      :transforms=>{},
  #      :source_type=>"na",
  #      :source_name=>nil,
  #      :namespace=>"collectionobjects_common",
  #      :xpath=>["otherNumberList", "otherNumber"],
  #      :data_type=>"string",
  #      :repeats=>"n",
  #      :in_repeating_group=>"y",
  #      :opt_list_values=>[],
  #      :datacolumn=>"numberValue",
  #      :required=>"n"
  let(:recordmapper) { instance_double('CS::Mapper::RecordMapper') }
  let(:mapping) { described_class.new(hash, recordmapper) }
  
  describe '#datacolumn' do
    let(:hash) { {:datacolumn=>"abCdeFg"} }
    it 'returns downcased column name' do
      expect(mapping.datacolumn).to eq('abcdefg')
    end
  end
  
  describe '#fullpath' do
    let(:hash) { {
        :namespace=>"collectionobjects_common",
        :xpath=>["otherNumberList", "otherNumber"],
      } }
    it 'returns full xpath to target CollectionSpace field' do
      expected = 'collectionobjects_common/otherNumberList/otherNumber'
      expect(mapping.fullpath).to eq(expected)
    end
  end

  describe '#required?' do
    context 'with required = y' do
      let(:hash) { { :required=>"y" } }
      it 'returns true' do
        expect(mapping.required?).to be true
      end
    end

    context 'with required = y in template' do
      let(:hash) { { :required=>"y in template" } }
      it 'returns true' do
        expect(mapping.required?).to be true
      end
    end

    context 'with required = n' do
      let(:hash) { { :required=>"n" } }
      it 'returns false' do
        expect(mapping.required?).to be false
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::SingleColumnRequiredField do
  let(:field){ described_class.new('objectNumber', ['objectNumber']) }

  describe '#present_in?' do
    context 'when data has field key' do
      it 'returns true' do
        data = {'objectnumber' => '123'}
        expect(field.present_in?(data)).to be true
      end
    end
    context 'when data lacks field key' do
      it 'returns false' do
        data = {'objectid' => '123'}
        expect(field.present_in?(data)).to be false
      end
    end
  end
  describe '#populated_in?' do
    context 'when field is populated' do
      it 'returns true' do
        data = {'objectnumber' => '123'}
        expect(field.populated_in?(data)).to be true
      end
    end
    context 'when field is not populated' do
      it 'returns false' do
        data = {'objectnumber' => ''}
        expect(field.populated_in?(data)).to be false
      end
    end
  end
  describe '#missing_message' do
    it 'returns expected message' do
      expected = 'required field missing: objectnumber must be present'
    end
  end
  describe '#empty_message' do
    it 'returns expected message' do
      expected = 'required field empty: objectnumber must be populated'
    end
  end
end

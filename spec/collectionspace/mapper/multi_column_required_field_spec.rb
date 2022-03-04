# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::MultiColumnRequiredField do
  let(:columns){ %w[currentLocationLocationLocal currentLocationLocationOffsite currentLocationOrganization] }
  let(:field){ described_class.new('currentLocation', columns) }

  describe '#present_in?' do
    context 'when data contains one of the field datacolumns' do
      it 'returns true' do
        data = {'currentLocationLocationLocal' => 'Big Room'}
        expect(field.present_in?(data)).to be true
      end
    end
    context 'when data lacks any of the field datacolumns' do
      it 'returns false' do
        data = {'objectid' => '123'}
        expect(field.present_in?(data)).to be false
      end
    end
  end
  describe '#populated_in?' do
    context 'when data contains one of the field datacolumns' do
      it 'returns true' do
        data = {'currentLocationLocationLocal' => 'Big Room'}
        expect(field.populated_in?(data)).to be true
      end
    end
    context 'when data lacks any of the field datacolumns' do
      it 'returns false' do
        data = {'currentLocationLocationLocal' => ''}
        expect(field.populated_in?(data)).to be false
      end
    end
  end
  describe '#missing_message' do
    it 'returns expected message' do
      expected = 'required field missing: currentlocation. At least one of the following fields must be present: currentLocationLocationLocal, currentLocationLocationOffsite, currentLocationOrganization'
    end
  end
  describe '#empty_message' do
    it 'returns expected message' do
      expected = 'required field empty: currentlocation. At least one of the following fields must be populated: currentLocationLocationLocal, currentLocationLocationOffsite, currentLocationOrganization'
    end
  end
end

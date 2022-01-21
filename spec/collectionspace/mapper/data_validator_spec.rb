# frozen_string_literal: true

require 'spec_helper'
RSpec.describe CollectionSpace::Mapper::SingleColumnRequiredField do
  before(:all) do
    @rf = CollectionSpace::Mapper::SingleColumnRequiredField.new('objectNumber', ['objectNumber'])
  end
  describe '#present_in?' do
    context 'when data has field key' do
      it 'returns true' do
        data = {'objectnumber' => '123'}
        expect(@rf.present_in?(data)).to be true
      end
    end
    context 'when data lacks field key' do
      it 'returns false' do
        data = {'objectid' => '123'}
        expect(@rf.present_in?(data)).to be false
      end
    end
  end
  describe '#populated_in?' do
    context 'when field is populated' do
      it 'returns true' do
        data = {'objectnumber' => '123'}
        expect(@rf.populated_in?(data)).to be true
      end
    end
    context 'when field is not populated' do
      it 'returns false' do
        data = {'objectnumber' => ''}
        expect(@rf.populated_in?(data)).to be false
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

RSpec.describe CollectionSpace::Mapper::MultiColumnRequiredField do
  before(:all) do
    columns = %w[currentLocationLocationLocal currentLocationLocationOffsite currentLocationOrganization]
    @rf = CollectionSpace::Mapper::MultiColumnRequiredField.new('currentLocation', columns)
  end
  describe '#present_in?' do
    context 'when data contains one of the field datacolumns' do
      it 'returns true' do
        data = {'currentLocationLocationLocal' => 'Big Room'}
        expect(@rf.present_in?(data)).to be true
      end
    end
    context 'when data lacks any of the field datacolumns' do
      it 'returns false' do
        data = {'objectid' => '123'}
        expect(@rf.present_in?(data)).to be false
      end
    end
  end
  describe '#populated_in?' do
    context 'when data contains one of the field datacolumns' do
      it 'returns true' do
        data = {'currentLocationLocationLocal' => 'Big Room'}
        expect(@rf.populated_in?(data)).to be true
      end
    end
    context 'when data lacks any of the field datacolumns' do
      it 'returns false' do
        data = {'currentLocationLocationLocal' => ''}
        expect(@rf.populated_in?(data)).to be false
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

RSpec.describe CollectionSpace::Mapper::DataValidator do
  before(:all) do
    @anthro_object_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_collectionobject.json')
    @anthro_dv = CollectionSpace::Mapper::DataValidator.new(
      CollectionSpace::Mapper::RecordMapper.new(mapper: @anthro_object_mapper, termcache: anthro_cache), anthro_cache
    )
    @botgarden_loanout_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/botgarden/botgarden_2-0-1_loanout.json')
    @botgarden_dv = CollectionSpace::Mapper::DataValidator.new(
      CollectionSpace::Mapper::RecordMapper.new(mapper: @botgarden_loanout_mapper,
                                                termcache: botgarden_cache), botgarden_cache
    )
    @core_authhier_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_authorityhierarchy.json')
    @core_authhier_dv = CollectionSpace::Mapper::DataValidator.new(
      CollectionSpace::Mapper::RecordMapper.new(mapper: @core_authhier_mapper, termcache: core_cache), core_cache
    )
  end

  describe '#validate' do
    it 'returns a CollectionSpace::Mapper::Response' do
      data = {'objectNumber' => '123'}
      expect(@anthro_dv.validate(data)).to be_a(CollectionSpace::Mapper::Response)
    end

    context 'when recordtype has multiauthority required field' do
      before(:all) do
        @mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_movement.json')
        @validator = CollectionSpace::Mapper::DataValidator.new(
          CollectionSpace::Mapper::RecordMapper.new(mapper: @mapper, termcache: core_cache), core_cache
        )
      end
      it 'validates' do
        data = {'movementReferenceNumber' => '1', 'currentLocationLocationLocal' => 'Loc'}
        v = @validator.validate(data)
        expect(v.valid?).to be true
      end
    end

    context 'when recordtype has required field(s)' do
      context 'and when required field present' do
        context 'and required field populated' do
          it 'no required field error returned' do
            data = {'objectNumber' => '123'}
            v = @anthro_dv.validate(data)
            err = v.errors.select{ |errhash| errhash[:type].start_with?('required field') }
            expect(err.size).to eq(0)
          end
        end

        context 'and required field present but empty' do
          it 'required field error returned with message "required field empty"' do
            data = {'objectNumber' => ''}
            v = @anthro_dv.validate(data)
            err = v.errors.select{ |err| err.start_with?('required field empty') }
            expect(err.size).to eq(1)
          end
        end
      end

      context 'when required field not present in data' do
        it 'required field error returned with message "required field missing"' do
          data = {'randomField' => 'random value'}
          v = @anthro_dv.validate(data)
          err = v.errors.select{ |err| err.start_with?('required field missing') }
          expect(err.size).to eq(1)
        end
      end

      context 'when required field not present in data but provided by defaults' do
        it 'no required field error returned', services_call: true do
          handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @core_authhier_mapper,
                                                             client: core_client,
                                                             cache: core_cache)
          data = get_datahash(path: 'spec/fixtures/files/datahashes/core/authorityHierarchy1.json')
          v = handler.validate(data)
          err = v.errors.select{ |err| err.start_with?('required field') }
          puts err
          expect(err.size).to eq(0)
        end
      end
    end

    context 'when recordtype has no required field(s)' do
      context 'and when record id field present' do
        context 'and record id field populated' do
          it 'no required field error returned' do
            data = {'loanOutNumber' => '123'}
            v = @botgarden_dv.validate(data)
            err = v.errors.select{ |err| err.start_with?('required field') }
            expect(err.size).to eq(0)
          end
        end

        context 'and record id field present but empty' do
          it 'required field error returned with message "required field empty"' do
            data = {'loanOutNumber' => ''}
            v = @botgarden_dv.validate(data)
            err = v.errors.select{ |err| err.start_with?('required field empty') }
            expect(err.size).to eq(1)
          end
        end
      end

      context 'when record id field not present in data' do
        it 'required field error returned with message "required field missing"' do
          data = {'randomField' => 'random value'}
          v = @botgarden_dv.validate(data)
          err = v.errors.select{ |err| err.start_with?('required field missing') }
          expect(err.size).to eq(1)
        end
      end
    end
  end
end

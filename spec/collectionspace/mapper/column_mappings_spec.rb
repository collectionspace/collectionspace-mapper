# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::ColumnMappings do
  let(:mappings) do
    [
      {fieldname: 'objectNumber',
       transforms: {},
       source_type: 'na',
       source_name: nil,
       namespace: 'collectionobjects_common',
       xpath: [],
       data_type: 'string',
       repeats: 'n',
       in_repeating_group: 'n/a',
       opt_list_values: [],
       datacolumn: 'objectNumber',
       required: 'y'},
      {fieldname: 'numberOfObjects',
       transforms: {},
       source_type: 'na',
       source_name: nil,
       namespace: 'collectionobjects_common',
       xpath: [],
       data_type: 'integer',
       repeats: 'n',
       in_repeating_group: 'n/a',
       opt_list_values: [],
       datacolumn: 'numberOfObjects',
       required: 'n'},
      {fieldname: 'numberValue',
       transforms: {},
       source_type: 'na',
       source_name: nil,
       namespace: 'collectionobjects_common',
       xpath: %w[otherNumberList otherNumber],
       data_type: 'string',
       repeats: 'n',
       in_repeating_group: 'y',
       opt_list_values: [],
       datacolumn: 'numberValue',
       required: 'n'},
      {fieldname: 'numberType',
       transforms: {},
       source_type: 'optionlist',
       source_name: 'numberTypes',
       namespace: 'collectionobjects_common',
       xpath: %w[otherNumberList otherNumber],
       data_type: 'string',
       repeats: 'n',
       in_repeating_group: 'y',
       opt_list_values: %w[lender obsolete previous serial unknown],
       datacolumn: 'numberType',
       required: 'n'},
      {datacolumn: 'otherRequired',
       required: 'y'}
    ]
  end

  let(:recordmapper){ instance_double('CS::Mapper::RecordMapper') }
  let(:mapperconfig){ instance_double('CS::Mapper::RecordMapperConfig') }

  let(:mappingsobj){ dc = described_class.new(mappings: mappings, mapper: recordmapper) }

  let(:added_field) do
    {
      fieldname: 'addedField',
      namespace: 'persons_common',
      data_type: 'string',
      xpath: [],
      required: 'not in input data',
      repeats: 'n',
      in_repeating_group: 'n/a',
      datacolumn: 'addedfield'
    }
  end

  before do
    allow(recordmapper).to receive(:config).and_return(mapperconfig)
    allow(recordmapper).to receive(:service_type_extension).and_return(nil)
  end

  context 'when initialized from authority RecordMapper' do
    it 'adds shortIdentifier to mappings' do
      allow(mapperconfig).to receive(:common_namespace).and_return('citations_common')
      allow(recordmapper).to receive(:service_type_extension).and_return(CS::Mapper::Authority)
      authmappings = described_class.new(mappings: mappings,
                                         mapper: recordmapper)
      expect(authmappings.known_columns.include?('shortidentifier')).to be true
    end
  end

  context 'when initialized from non-authority RecordMapper' do
    it 'does not add shortIdentifier to mappings' do
      expect(mappingsobj.known_columns.include?('shortidentifier')).to be false
    end
  end

  context 'when initialized from media RecordMapper' do
    let(:mappings) do
      [
        {fieldname: 'identificationNumber',
         transforms: {},
         source_type: 'na',
         source_name: nil,
         namespace: 'media_common',
         xpath: [],
         data_type: 'string',
         repeats: 'n',
         in_repeating_group: 'n/a',
         opt_list_values: [],
         datacolumn: 'identificationNumber',
         required: 'y'},
        {fieldname: 'title',
         transforms: {},
         source_type: 'na',
         source_name: nil,
         namespace: 'media_common',
         xpath: [],
         data_type: 'string',
         repeats: 'n',
         in_repeating_group: 'n/a',
         opt_list_values: [],
         datacolumn: 'title',
         required: 'n'}
      ]
    end

    it 'adds mediaFileURI to mappings' do
      allow(mapperconfig).to receive(:common_namespace).and_return('media_common')
      allow(recordmapper).to receive(:service_type_extension).and_return(CS::Mapper::Media)

      mediamappings = described_class.new(mappings: mappings,
                                          mapper: recordmapper)
      expect(mediamappings.known_columns.include?('mediafileuri')).to be true
    end
  end

  describe '#known_columns' do
    it 'returns list of downcased datacolumns' do
      expected = %w[objectnumber numberofobjects numbervalue numbertype otherrequired].sort
      expect(mappingsobj.known_columns.sort).to eq(expected)
    end
  end

  describe '#required_columns' do
    it 'returns column mappings for required fields' do
      expect(mappingsobj.required_columns.map(&:datacolumn).sort.join(' ')).to eq('objectnumber otherrequired')
    end
  end

  describe '#<<' do
    it 'adds a mapping' do
      mappings << added_field
      expect(mappingsobj.known_columns.include?('addedfield')).to be true
    end
  end

  describe '#lookup' do
    it 'returns ColumnMapping for column name' do
      result = mappingsobj.lookup('numberType').fieldname
      expect(result).to eq('numberType')
    end
  end
end

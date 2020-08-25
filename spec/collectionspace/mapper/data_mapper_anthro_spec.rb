# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  before(:all) do
    @config = {
      delimiter: ';',
      subgroup_delimiter: '^^'
    }
  end

  context 'anthro profile' do
    before(:all) do
      populate_anthro(anthro_cache)
    end
    
    context 'collectionobject record' do
      before(:all) do
        @rm_anthro_co = get_json_record_mapper(path: 'spec/fixtures/files/mappers/anthro_4_0_0-collectionobject.json')
        @dh = DataHandler.new(record_mapper: @rm_anthro_co, cache: anthro_cache, client: anthro_client, config: @config)
      end
      # record 1 was used for testing default value merging, transformations, etc.
      # we start with record 2 to purely test mapping functionality
      context 'rec 2' do
        let(:datahash) { get_datahash(path: 'spec/fixtures/files/datahashes/anthro/collectionobject2.json') }
        let(:prepper) { DataPrepper.new(datahash, @dh) }
        let(:prepped) { prepper.prep }
        let(:dm) { DataMapper.new(prepped, @dh, prepper.xphash) }
        let(:testdoc) { get_xml_fixture('anthro/collectionobject1.xml') }
        let(:resdoc) { remove_namespaces(dm.doc) }
        let!(:xpaths) { test_xpaths(testdoc, @dh.mapper[:mappings]) } 
        
        it 'maps as expected' do
          xpaths.each do |xpath|
            #puts xpath
            testnode = standardize_value(testdoc.xpath(xpath).text)
            resnode = standardize_value(resdoc.xpath(xpath).text)
            expect(resnode).to eq(testnode)
          end
        end
      end
    end
  end
end
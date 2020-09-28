# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  before(:all) do
    @config = CollectionSpace::Mapper::DEFAULT_CONFIG
  end

  context 'anthro profile' do
    before(:all) do
      @client = anthro_client
      @cache = anthro_cache
      populate_anthro(@cache)
    end
  
    context 'claim record' do
      # Tests for claim record are pending because changes must be made to
      # handling of repeating field groups which contain more than one
      # field which may be populated by multiple authorities.
      # Problem in claimantGroupList
      before(:all) do
        @claimmapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4_1_0-claim.json')
        @handler = DataHandler.new(@claimmapper, @client, @cache, @config)
      end
      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/anthro/claim1.json')
          @prepper = DataPrepper.new(@datahash, @handler)
          @mapper = DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('anthro/claim1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper[:mappings])
        end
        xit 'does not map unexpected fields' do
          diff = @mapped_xpaths - @fixture_xpaths
          expect(diff).to eq([])
        end

        xit 'maps as expected' do
          puts @mapped_doc
          @fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(@fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(@mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'collectionobject record' do
      before(:all) do
        @collectionobjectmapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4_1_0-collectionobject.json')
        @handler = DataHandler.new(@collectionobjectmapper, @client, @cache, @config)
      end
      # record 1 was used for testing default value merging, transformations, etc.
      # we start with record 2 to purely test mapping functionality
      context 'record 2' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/anthro/collectionobject2.json')
          @prepper = DataPrepper.new(@datahash, @handler)
          @mapper = DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('anthro/collectionobject1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper[:mappings])
        end
        it 'does not map unexpected fields' do
          diff = @mapped_xpaths - @fixture_xpaths
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          @fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(@fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(@mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'osteology record' do
      before(:all) do
        @osteologymapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4_1_0-osteology.json')
        @handler = DataHandler.new(@osteologymapper, @client, @cache, @config)
      end
      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/anthro/osteology1.json')
          @prepper = DataPrepper.new(@datahash, @handler)
          @mapper = DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('anthro/osteology1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper[:mappings])
        end
        it 'does not map unexpected fields' do
          diff = @mapped_xpaths - @fixture_xpaths
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          @fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(@fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(@mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end
  end
end

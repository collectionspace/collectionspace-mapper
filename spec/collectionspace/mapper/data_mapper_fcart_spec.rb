# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  before(:all) do
    @config = CollectionSpace::Mapper::DEFAULT_CONFIG
  end

  context 'customized fcart profile' do
    before(:all) do
      @client = fcart_client
      @cache = ba_cache
      populate_fcart(@cache)
    end

    context 'collectionobject record' do
      before(:all) do
        @collectionobject_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/fcart/fcart_3_0_1-collectionobject.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @collectionobject_mapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/fcart/collectionobject1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('fcart/collectionobject1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper[:mappings])
        end
        xit 'does not map unexpected fields' do
          diff = @mapped_xpaths - @fixture_xpaths
          expect(diff).to eq([])
        end

        xit 'maps as expected' do
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

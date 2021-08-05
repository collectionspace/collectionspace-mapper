# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  before(:all) do
    @config = {}
  end

  context 'fcart profile' do
    before(:all) do
      @client = fcart_client
      @cache = fcart_cache
    end

    context 'acquisition record' do
      before(:all) do
        @acq_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/fcart/fcart_3-0-1_acquisition.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @acq_mapper, client: @client, cache: @cache, config: @config)
      end

      it 'maps records as expected in sequence' do
        data1 = JSON.parse("{\"creditline\":\"Gift of Frances, 1985\",\"accessiondategroup\":\"1985\",\"acquisitionmethod\":\"unknown-provenance\",\"acquisitionreferencenumber\":\"ACC216 (migrated accession)\",\"acquisitionsourceperson\":\"\",\"acquisitionsourceorganization\":\"\",\"acquisitionauthorizer\":\"\",\"acquisitionnote\":\"\"}")
        data2 = JSON.parse("{\"creditline\":\"\",\"accessiondategroup\":\"\",\"acquisitionmethod\":\"unknown-provenance\",\"acquisitionreferencenumber\":\"ACC215 (migrated accession)\",\"acquisitionsourceperson\":\"\",\"acquisitionsourceorganization\":\"\",\"acquisitionauthorizer\":\"\",\"acquisitionnote\":\"\"}")
        data3 = JSON.parse("{\"creditline\":\"Gift of Elizabeth, 1985\",\"accessiondategroup\":\"1985\",\"acquisitionmethod\":\"gift\",\"acquisitionreferencenumber\":\"ACC208 (migrated accession)\",\"acquisitionsourceperson\":\"Elizabeth\",\"acquisitionsourceorganization\":\"\",\"acquisitionauthorizer\":\"\",\"acquisitionnote\":\"Acquisition source role(s): Donor\"}")
        data = [data1, data2, data3]
        preppers = data.map{ |d| CollectionSpace::Mapper::DataPrepper.new(d, @handler) }
        mappers = preppers.map{ |prepper| CollectionSpace::Mapper::DataMapper.new(prepper.prep.response, @handler, prepper.xphash) }
        docs = mappers.map{ |mapper| remove_namespaces(mapper.response.doc) }
        docxpaths = docs.map{ |doc| list_xpaths(doc) }

        fixpaths = ['fcart/acqseq1.xml', 'fcart/acqseq2.xml', 'fcart/acqseq3.xml']
        fixdocs = fixpaths.map{ |path| get_xml_fixture(path) }
        fixxpaths = fixdocs.map{ |doc| list_xpaths(doc) }
        
        expect(docxpaths).to eq(fixxpaths)
      end
      
    end
  end
  
  context 'core profile' do
    before(:all) do
      @client = core_client
      @cache = core_cache
    end
    context 'collectionobject record' do
      before(:all) do
        @collectionobject_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_collectionobject.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @collectionobject_mapper, client: @client, cache: @cache)
        
      end
      context 'overflow subgroup record with uneven subgroup values' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/collectionobject2.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep.response, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/collectionobject2.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
        end
        it 'mapper response includes overflow subgroup warning' do
          w = @mapper.response.warnings.any?{ |w| w[:category] == :subgroup_contains_data_for_nonexistent_groups }
          expect(w).to be true
        end
        it 'mapper response includes uneven subgroup values warning' do
          w = @mapper.response.warnings.any?{ |w| w[:category] == :uneven_subgroup_field_values }
          expect(w).to be true
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

      context 'overflow subgroup record with even subgroup values' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/collectionobject3.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep.response, @handler, @prepper.xphash)
        end
        it 'mapper response does not include overflow subgroup warning' do
          w = @mapper.response.warnings.any?{ |w| w[:category] == :subgroup_contains_data_for_nonexistent_groups }
          expect(w).to be false
        end
      end
    end

    context 'media record' do
      before(:all) do
        @media_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_media.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @media_mapper, client: @client, cache: @cache)
        
      end
      context 'sending through the bomb emoji' do
        it 'sends through an empty node for any field containing bomb' do
          datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/media2.json')
          prepper = CollectionSpace::Mapper::DataPrepper.new(datahash, @handler)
          mapper = CollectionSpace::Mapper::DataMapper.new(prepper.prep.response, @handler, prepper.xphash)
          doc = remove_namespaces(mapper.response.doc)
          xpaths = list_xpaths(doc).reject{ |xpath| xpath['identificationNumber'] }
          vals = []
          xpaths.each{ |xpath| vals << doc.xpath(xpath).text }
          expect(vals.uniq).to eq([''])
        end
      end
    end
  end
  
  context 'lhmc profile' do
    before(:all) do
      @client = lhmc_client
      @cache = lhmc_cache
    end
    context 'person record' do
      before(:all) do
        @recmapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/lhmc/lhmc_3-1-1_person-local.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @recmapper, client: @client, cache: @cache)
        @prepper = CollectionSpace::Mapper::DataPrepper.new({'termDisplayName' => 'Xanadu', 'placeNote' => 'note'}, @handler)
        @datamapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep.response, @handler, @prepper.xphash)
        @mapped_doc = remove_namespaces(@datamapper.response.doc)
      end

      describe '#add_short_id' do
        before(:all) do
          @short_id_nodeset = @mapped_doc.xpath('//shortIdentifier')
        end
        it 'adds one shortIdentifier element' do
          expect(@short_id_nodeset.length).to eq(1)
        end
        it 'adds shortIdentifier element to persons_common namespace group' do
          node = @short_id_nodeset.first
          expect(node.parent.name).to eq('persons_common')
        end
        it 'value of shortIdentifier is as expected' do
          node = @short_id_nodeset.first
          expect(node.text).to eq('Xanadu2760257775')
        end
      end

      describe '#set_response_identifier' do
        before(:all){ @response = @datamapper.response }
        it 'adds record identifier to response' do
          expect(@response.identifier).to eq('Xanadu2760257775')
        end
      end
    end
  end
  

  context 'botgarden profile' do
    before(:all) do
      @client = botgarden_client
      @cache = botgarden_cache
    end
    context 'loanout record' do
      before(:all) do
        @recmapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/botgarden/botgarden_2-0-1_loanout.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @recmapper, client: @client, cache: @cache)
        @prepper = CollectionSpace::Mapper::DataPrepper.new({'loanOutNumber' => '123', 'sterile' => 'n'}, @handler)
        @datamapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep.response, @handler, @prepper.xphash)
      end

      describe '#set_response_identifier' do
        before(:all){ @response = @datamapper.response }
        it 'adds record identifier to response' do
          expect(@response.identifier).to eq('123')
        end
      end
    end
  end

  context 'anthro profile' do
    before(:all) do
      @client = anthro_client
      @cache = anthro_cache
    end
    context 'place record' do
      before(:all) do
        @recmapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_place-local.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @recmapper, client: @client, cache: @cache)
        @prepper = CollectionSpace::Mapper::DataPrepper.new({'termDisplayName' => 'Xanadu'}, @handler)
        @datamapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep.response, @handler, @prepper.xphash)
      end

      describe '#add_short_id' do
        it 'adds shortIdentifier' do
          
        end
      end
    end

    context 'collectionobject record', services_call: true do
      before(:all) do
        config = {
          transforms: {
            'collection' => {
              special: %w[downcase_value],
              replacements: [
                { find: ' ', replace: '-', type: :plain }
              ]
            },
            'ageRange' => {
              special: %w[downcase_value],
              replacements: [
                { find: ' - ', replace: '-', type: :plain }
              ]
            }
          },
          default_values: {
            'publishTo' => 'DPLA;Omeka',
            'collection' => 'library-collection'
          },
        }

        @recmapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_collectionobject.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @recmapper, client: @client, cache: @cache, config: config)
        @prepper = CollectionSpace::Mapper::DataPrepper.new(anthro_co_1, @handler)
        @datamapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep.response, @handler, @prepper.xphash)
      end

      describe '#doc' do
        it 'returns XML doc' do
          res = @datamapper.doc
          expect(res).to be_a(Nokogiri::XML::Document)
        end
      end

      describe '#response' do
        it 'returns CollectionSpace::Mapper::Response object' do
          res = @datamapper.response
          expect(res).to be_a(CollectionSpace::Mapper::Response)
        end
        it 'CollectionSpace::Mapper::Response.doc is XML document' do
          res = @datamapper.response.doc
          expect(res).to be_a(Nokogiri::XML::Document)
        end
      end
      
      describe '#add_namespaces' do
        it 'adds namespace definitions' do
          urihash = @datamapper.handler.mapper.config.ns_uri.clone
          urihash.transform_keys!{ |k| "ns2:#{k}" }
          docdefs = {}
          @datamapper.doc.xpath('/*/*').each do |ns|
            docdefs[ns.name] = ns.namespace_definitions.select{ |d| d.prefix == 'ns2' }.first.href
          end
          unused_keys = urihash.keys - docdefs.keys
          unused_keys.each{ |k| urihash.delete(k) }
          expect(docdefs).to eq(urihash)
        end
      end
    end
  end

  describe '#add_namespaces' do
    xit 'adds botgarden propagation namespace' do
      client = botgarden_client
      cache = botgarden_cache
      prop_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/botgarden/botgarden_2-0-1_propagation.json')
      prop_handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: prop_mapper,
                                                              client: client,
                                                              cache: cache,
                                                              config: CollectionSpace::Mapper::DEFAULT_CONFIG)
      datahash = get_datahash(path: 'spec/fixtures/files/datahashes/botgarden/propagation1.json')
      prepper = CollectionSpace::Mapper::DataPrepper.new(datahash, prop_handler)
      mapper = CollectionSpace::Mapper::DataMapper.new(prepper.prep.response, prop_handler, prepper.xphash)
    end
  end
end

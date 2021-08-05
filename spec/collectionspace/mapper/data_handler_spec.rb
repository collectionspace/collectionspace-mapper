# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataHandler do
  before(:all) do
    @anthro_client = anthro_client
    @anthro_cache = anthro_cache
    @anthro_object_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_collectionobject.json')
    @anthro_object_handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @anthro_object_mapper,
                                                                      client: @anthro_client,
                                                                      cache: @anthro_cache)
    @anthro_place_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_place-local.json')
    @anthro_place_handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @anthro_place_mapper,
                                                                     client: @anthro_client,
                                                                     cache: @anthro_cache)

    @bonsai_client = bonsai_client
    @bonsai_cache = bonsai_cache
    @bonsai_conservation_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/bonsai/bonsai_4-1-1_conservation.json')
    @bonsai_conservation_handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @bonsai_conservation_mapper,
                                                                            client: @bonsai_client,
                                                                            cache: @bonsai_cache)
end

  # todo: why are these making services api calls?
  context 'when config has check_terms = false', services_call: true do
    before(:all) do
      @client = core_client
      @cache = core_cache_search
      @mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_collectionobject.json')
      @config = '{"check_terms": false}'
      @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @mapper,
                                                          client: @client,
                                                          cache: @cache,
                                                          config: @config)
      @data = {"objectNumber"=>"20CS.001.0002",
               "numberOfObjects"=>"1",
               "title"=>"Rainbow",
               "titleLanguage"=>"English",
               "namedCollection"=>"Test Collection",
               "collection"=>"rando"}
      @data2 = {"objectNumber"=>"20CS.001.0001",
                "numberOfObjects"=>"1",
                "numberValue"=>"123456|98765",
                "numberType"=>"lender|obsolete",
                "title"=>"A Man| A Woman",
                "titleLanguage"=>"English| Klingon",
                "namedCollection"=>"Test collection",
                "collection"=>"permanent collection"}
    end
    it 'returns found = false for all terms, even if they exist in client' do
      res = @handler.process(@data)
      not_found = res.terms.reject{ |t| t[:found] }
      expect(not_found.length).to eq(2)
    end
    it 'returns found = false for all terms, even if they exist in client' do
      res = @handler.process(@data2)
      not_found = res.terms.reject{ |t| t[:found] }
      expect(not_found.length).to eq(3)
    end
  end

  it 'tags all un-found terms as such', services_call: true do
    data1 = {
      'objectNumber' => '1',
      'publishTo' => 'Wordpress', #vocabulary - not in cache
      'namedCollection' => 'nc', #authority - not in cache
    }
    data2 = {
      'objectNumber' => '2',
      'publishTo' => 'Wordpress', #vocabulary - now in cache
      'namedCollection' => 'nc', #authority - now in cache
      'contentConceptAssociated' => 'Birds' # authority, in cache
    }
    @anthro_object_handler.process(data1)
    result = @anthro_object_handler.process(data2).terms.select{ |t| t[:found] == false }
    expect(result.length).to eq(2)
  end
  
  describe '#is_authority' do
    context 'anthro profile' do
      context 'place record' do
        it 'adds a xphash entry for shortIdentifier' do
          result = @anthro_place_handler.mapper.xpath['places_common'][:mappings].select do |mapping|
            mapping.fieldname == 'shortIdentifier'
          end
          expect(result.length).to eq(1)
        end
      end
    end
  end

  describe '#service_type' do
    let(:servicetype) { handler.service_type }
    context 'anthro profile' do
      context 'collectionobject record' do
        let(:handler) { @anthro_object_handler }

        it 'returns object' do
          expect(servicetype).to eq('object')
        end
      end

      context 'place record' do
        let(:handler) { @anthro_place_handler }

        it 'returns authority' do
          expect(servicetype).to eq('authority')
        end
      end
    end

    context 'bonsai profile' do
      context 'conservation record' do
        let(:handler) { @bonsai_conservation_handler }

        it 'returns procedure' do
          expect(servicetype).to eq('procedure')
        end
      end
    end
  end
  
  describe '#xpath_hash' do
    context 'anthro profile' do
      context 'collectionobject record' do
        context 'xpath ending with commingledRemainsGroup' do
          before(:all) do
            xpath = 'collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup'
            @h = @anthro_object_handler.mapper.xpath[xpath]
          end
          it 'is_group = true' do
            expect(@h[:is_group]).to be true
          end

          it 'is_subgroup = false' do
            expect(@h[:is_subgroup]).to be false
          end

          it 'includes mortuaryTreatment as subgroup' do
            xpath = 'collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup/mortuaryTreatmentGroupList/mortuaryTreatmentGroup'
            expect(@h[:children]).to eq([xpath])
          end

          xit 'has mortuaryTreatment listed as only child' do
          end
        end

        context 'xpath ending with mortuaryTreatmentGroup' do
          before(:all) do
            xpath = 'collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup/mortuaryTreatmentGroupList/mortuaryTreatmentGroup'
            @h = @anthro_object_handler.mapper.xpath[xpath]
          end
          it 'is_group = true' do
            expect(@h[:is_group]).to be true
          end

          it 'is_subgroup = true' do
            expect(@h[:is_subgroup]).to be true
          end

          it 'parent is xpath ending with commingledRemainsGroup' do
            ppath = 'collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup'
            expect(@h[:parent]).to eq(ppath)
          end
        end

        context 'xpath ending with collectionobjects_nagpra' do
          before(:all) do
            @h = @anthro_object_handler.mapper.xpath['collectionobjects_nagpra']
          end
          it 'has 5 children' do
            expect(@h[:children].size).to eq(5)
          end
        end
      end
    end
context 'bonsai profile' do
  context 'conservation record type' do
    context 'xpath ending with fertilizersToBeUsed' do
      it 'is a repeating group' do
        h = @bonsai_conservation_handler.mapper.xpath
        res = h['conservation_livingplant/fertilizationGroupList/fertilizationGroup/fertilizersToBeUsed'][:is_group]
        expect(res).to be true
      end
    end
    context 'xpath ending with conservators' do
      it 'is a repeating group' do
        h = @bonsai_conservation_handler.mapper.xpath
        res = h['conservation_common/conservators'][:is_group]
        expect(res).to be false
      end
    end
  end
end
  end

  describe '#validate' do
    it 'returns CollectionSpace::Mapper::Response object' do
      data = { 'objectNumber' => '123' }
      result = @anthro_object_handler.validate(data)
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end
  end

  describe '#check_fields' do
    before(:all) do
      @data = {
        'conservationNumber' => '123',
        'status' => 'good',
        'conservator' => 'Someone'
      }
    end
    it 'returns expected hash' do
      expect = {
        known_fields: %w[conservationnumber status],
        unknown_fields: %w[conservator]
      }
    end
  end
  
  describe '#prep' do
    before(:all) do
      @data = { 'objectNumber' => '123' }
    end
    it 'can be called with response from validation' do
      vresult = @anthro_object_handler.validate(@data)
      result = @anthro_object_handler.prep(vresult).response
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end
    it 'can be called with just data' do
      result = @anthro_object_handler.prep(@data).response
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end
    context 'when response_mode = normal' do
      it 'returned response to include detailed data transformation info needed for mapping' do
        result = @anthro_object_handler.prep(@data).response
        expect(result.transformed_data).not_to be_empty
      end
    end
    context 'when response_mode = verbose' do
      it 'returned response includes detailed data transformation info' do
        config = { response_mode: 'verbose' }
        handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @anthro_object_mapper,
                                                           client: @anthro_client,
                                                           cache: @anthro_cache,
                                                           config: config)
        result = handler.prep(@data).response
        expect(result.transformed_data).not_to be_empty
      end
    end
  end

  describe '#process', services_call: true do
    before(:all) do
      @data = { 'objectNumber' => '123' }
    end
    it 'can be called with response from validation' do
      vresult = @anthro_object_handler.validate(@data)
      result = @anthro_object_handler.process(vresult)
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end
    it 'can be called with just data' do
      result = @anthro_object_handler.process(@data)
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end
    context 'when response_mode = normal' do
      it 'returned response omits detailed data transformation info' do
        result = @anthro_object_handler.process(@data)
        expect(result.transformed_data).to be_empty
      end
    end
    context 'when response_mode = verbose' do
      it 'returned response includes detailed data transformation info' do
        config = { response_mode: 'verbose' }
        handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @anthro_object_mapper,
                                                           client: @anthro_client,
                                                           cache: @anthro_cache,
                                                           config: config)
        result = handler.process(@data)
        expect(result.transformed_data).not_to be_empty
      end
    end
  end
  
  describe '#map', services_call: true do
    before(:all) do
      @data = { 'objectNumber' => '123' }
      prepper = CollectionSpace::Mapper::DataPrepper.new(@data, @anthro_object_handler)
      prep_response = @anthro_object_handler.prep(@data).response
      @result = @anthro_object_handler.map(prep_response, prepper.xphash)
    end
    
    it 'returns CollectionSpace::Mapper::Response object' do
      expect(@result).to be_a(CollectionSpace::Mapper::Response)
    end

    it 'the CollectionSpace::Mapper::Response object doc attribute is a Nokogiri XML Document' do
      expect(@result.doc).to be_a(Nokogiri::XML::Document)
    end
    context 'when response_mode = normal' do
      it 'returned response omits detailed data transformation info' do
        expect(@result.transformed_data).to be_empty
      end
    end
    context 'when response_mode = verbose' do
      it 'returned response includes detailed data transformation info' do
        config = { 'response_mode'=> 'verbose' }
        handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @anthro_object_mapper,
                                                           client: @anthro_client,
                                                           cache: @anthro_cache,
                                                           config: config)
        prepper = CollectionSpace::Mapper::DataPrepper.new(@data, handler)
        result = handler.map(handler.prep(@data).response, prepper.xphash)
        expect(result.transformed_data).not_to be_empty
      end
    end
  end
end

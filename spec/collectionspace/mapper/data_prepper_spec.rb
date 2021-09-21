# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataPrepper do
  before(:all) do
    @config = {delimiter: ';'}
  end

  context 'anthro profile' do
    before(:all) do
      @client = anthro_client
      @cache = anthro_cache
      @collectionobject_config = @config.merge({
        transforms: {
          'collection' => {
            special: %w[downcase_value],
            replacements: [
              {find: ' ', replace: '-', type: :plain}
            ]
          },
          'ageRange' => {
            special: %w[downcase_value],
          }
        },
        default_values: {
          'publishTo' => 'DPLA;Omeka',
          'collection' => 'library-collection'
        },
        force_defaults: false
      })

      @collectionobject_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_collectionobject.json')
      @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @collectionobject_mapper,
                                                          client: @client,
                                                          cache: @cache,
                                                          config: @collectionobject_config)
      @prepper = CollectionSpace::Mapper::DataPrepper.new(anthro_co_1, @handler)
    end

    describe '#merge_default_values' do
      context 'when no default_values specified in config' do
        it 'does not fall over' do
          dp = CollectionSpace::Mapper::DataPrepper.new(anthro_co_1, @handler)
          res = dp.prep.response.merged_data['collection']
          ex = 'Permanent Collection'
          expect(res).to eq(ex)
        end
      end
      context 'when default_values for a field is specified in config' do
        context 'and no value is given for that field in the incoming data' do
          it 'maps the default values' do
            res = @prepper.prep.response.merged_data['publishto']
            ex = 'DPLA;Omeka'
            expect(res).to eq(ex)
          end
        end
        context 'and value is given for that field in the incoming data' do
          context 'and :force_defaults = false' do
            it 'maps the value in the incoming data' do
              res = @prepper.prep.response.merged_data['collection']
              ex = 'Permanent Collection'
              expect(res).to eq(ex)
            end
          end
          context 'and :force_defaults = true' do
            it 'maps the default value, overwriting value in the incoming data', services_call: true do
              config = CS::Mapper::Config.new(config: {
                default_values: {
                  'collection' => 'library-collection'
                },
                force_defaults: true
              })
              dh = CollectionSpace::Mapper::DataHandler.new(
                record_mapper: @collectionobject_mapper,
                client: @client,
                cache: @cache,
                config: config
              )
              dp = CollectionSpace::Mapper::DataPrepper.new(anthro_co_1, dh)
              res = dp.prep.response.merged_data['collection']
              ex = 'library-collection'
              expect(res).to eq(ex)
            end
          end
        end
      end
    end

    context 'core profile' do
      before(:all) do
        @client = core_client
        @cache = core_cache
      end
      describe '#process_xpaths' do
        context 'when authority record' do
          before(:all) do
            @place_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_place-local.json')
            @place_handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @place_mapper, client: @client,
                                                                      cache: @cache, config: @config)
            data = get_datahash(path: 'spec/fixtures/files/datahashes/core/place001.json')
            @place_prepper = CollectionSpace::Mapper::DataPrepper.new(data, @place_handler)
          end
          it 'keeps mapping for shortIdentifier in xphash' do
            @place_prepper.prep
            result = @place_prepper.xphash['places_common'][:mappings].select do |mapping|
              mapping.fieldname == 'shortIdentifier'
            end
            expect(result.length).to eq(1)
          end
        end
      end

      describe '#handle_term_fields' do
        before(:all) do
          @prepper = CollectionSpace::Mapper::DataPrepper.new(anthro_co_1, @handler)
          @prepped = @prepper.prep
        end
        it 'returns expected result for mapping' do
          res = @prepped.response.transformed_data['titletranslationlanguage']
          expected = [["urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(fra)'French'",
                       "urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(spa)'Spanish'"],
                      ["urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(fra)'French'",
                       "urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(deu)'German'"]]
          expect(res).to eq(expected)
        end
        it 'adds expected term Hashes to response.terms' do
          chk = @prepped.response.terms.select{ |t| t[:field] == 'titletranslationlanguage' }
          expect(chk.length).to eq(4)
        end
      end

      describe '#transform_date_fields' do
        context 'when field is a structured date' do
          it 'results in mappable structured date hashes' do
            res = @prepper.prep.response.transformed_data['identdategroup']
            chk = res.map{ |e| e.class }.uniq
            expect(chk).to eq([Hash])
          end
        end
        context 'when field is an unstructured date' do
          it 'results in array of datestamp strings' do
            res = @prepper.prep.response.transformed_data['annotationdate']
            chk = res.select{ |e| e['T00:00:00.000Z'] }
            expect(chk.size).to eq(2)
          end
        end
      end

      describe '#combine_data_values' do
        context 'when multi-authority field is not part of repeating field group' do
          it 'combines values properly' do
            xpath = 'collectionobjects_common/fieldCollectors'
            result = @prepper.prep.response.combined_data[xpath]['fieldCollector']
            expected = ["urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(AnnAnalyst1594848799340)'Ann Analyst'",
                        "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(GabrielSolares1594848906847)'Gabriel Solares'",
                        "urn:cspace:anthro.collectionspace.org:orgauthorities:name(organization):item:name(Organization11587136583004)'Organization 1'"]
            expect(result).to eq(expected)
          end
        end
        context 'when multi-authority field is part of repeating field group' do
          it 'combines values properly' do
            xpath = 'collectionobjects_common/objectProductionPeopleGroupList/objectProductionPeopleGroup'
            result = @prepper.prep.response.combined_data[xpath]['objectProductionPeople']
            expected = [
              "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(archculture):item:name(Blackfoot1576172504869)'Blackfoot'",
              "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(ethculture):item:name(Batak1576172496916)'Batak'"
            ]
            expect(result).to eq(expected)
          end

          context 'and one or more combined field values is blank' do
            before(:all) do
              @core_conservation_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_conservation.json')
              @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @core_conservation_mapper,
                                                                  client: @client, cache: @cache, config: @config)
              data = get_datahash(path: 'spec/fixtures/files/datahashes/core/conservation0_1.json')
              @prepper = CollectionSpace::Mapper::DataPrepper.new(data, @handler)
              @xpath = 'conservation_common/conservationStatusGroupList/conservationStatusGroup'
            end
            it 'removes empty fields from combined data response' do
              result = @prepper.prep.response.combined_data[@xpath].keys
              expect(result).to_not include('statusDate')
            end
            it 'removes empty fields from fieldmapping list passed on for mapping' do
              @prepper.prep
              result = @prepper.xphash[@xpath][:mappings]
              expect(result.length).to eq(1)
            end
          end
        end
        context 'when multi-authority field is part of repeating field subgroup' do
          before(:all) do
            @core_media_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_media.json')
            @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @core_media_mapper, client: @client,
                                                                cache: @cache, config: @config)
          end

          context 'when there is more than one group' do
            before(:all) do
              data = get_datahash(path: 'spec/fixtures/files/datahashes/core/media1_1.json')
              @prepper = CollectionSpace::Mapper::DataPrepper.new(data, @handler)
            end
            # todo: why does this call services api?
            it 'combines values properly', services_call: true do
              xpath = 'media_common/measuredPartGroupList/measuredPartGroup/dimensionSubGroupList/dimensionSubGroup'
              result = @prepper.prep.response.combined_data[xpath]['measuredBy']
              expected = [
                [
                  "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Gomongo1599463746195)'Gomongo'",
                  "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Comodore1599463826401)'Comodore'",
                  "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Cuckoo1599463786824)'Cuckoo'",
                  ''],
                [
                  "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Gomongo1599463746195)'Gomongo'",
                  "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Cuckoo1599463786824)'Cuckoo'",
                ]
              ]
              expect(result).to eq(expected)
            end
          end
          context 'when there is only one group' do
            before(:all) do
              data = get_datahash(path: 'spec/fixtures/files/datahashes/core/media1_2.json')
              @prepper = CollectionSpace::Mapper::DataPrepper.new(data, @handler)
            end
            it 'combines values properly' do
              xpath = 'media_common/measuredPartGroupList/measuredPartGroup/dimensionSubGroupList/dimensionSubGroup'
              result = @prepper.prep.response.combined_data[xpath]['measuredBy']
              expected = [
                [
                  "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Gomongo1599463746195)'Gomongo'",
                  "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Comodore1599463826401)'Comodore'",
                  "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Cuckoo1599463786824)'Cuckoo'",
                  ''],
              ]
              expect(result).to eq(expected)
            end
          end
        end
      end

      describe '#prep' do
        before(:all) do
          @res = @prepper.prep
        end
        it 'returns self' do
          expect(@res).to be_a(CollectionSpace::Mapper::DataPrepper)
        end
        it 'response contains orig data hash' do
          expect(@res.response.orig_data).not_to be_empty
        end
        it 'response contains merged data hash' do
          expect(@res.response.merged_data).not_to be_empty
        end
        it 'response contains split data hash' do
          expect(@res.response.split_data).not_to be_empty
        end
        it 'response contains transformed data hash' do
          expect(@res.response.transformed_data).not_to be_empty
        end
        it 'response contains combined data hash' do
          expect(@res.response.combined_data).not_to be_empty
        end
      end

      describe '#check_data' do
        it 'returns array' do
          expect(@prepper.check_data).to be_a(Array)
        end
      end
    end
  end
end

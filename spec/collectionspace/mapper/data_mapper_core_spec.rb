# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  let(:config){ {delimiter: ';'} }

  context 'core profile' do
    let(:client){ core_client }
    let(:cache){ core_cache }
    let(:handler) do
      CollectionSpace::Mapper::DataHandler.new(record_mapper: mapper,
                                               client: client,
                                               cache: cache,
                                               config: config)
    end
    let(:datahash){ get_datahash(path: hashpath) }
    let(:response){ handler.process(datahash) }
    let(:mapped_doc){ remove_namespaces(response.doc) }
    let(:mapped_xpaths){ list_xpaths(mapped_doc) }
    let(:fixture_doc){ get_xml_fixture(fixturepath) }
    let(:fixture_xpaths){ test_xpaths(fixture_doc, handler.mapper.mappings) }
    let(:diff){ mapped_xpaths - fixture_xpaths }

    context 'non-hierarchical relationship record', services_call: true do
      # NOTE!
      # These tests are prone to failing if one of the records used in the test in core.dev is deleted
      # If a UUID is expected but you get blank, recreate the record in core.dev, rerun the test to
      #   get the UUID for the new record, and replace the old UUID in both fixture XML files used.
      let(:mapper) do
        get_json_record_mapper(
          'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_nonhierarchicalrelationship.json'
        )
      end

      context 'when all IDs found' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/nonHierarchicalRelationship1.json' }
        let(:mapped_doc1){ remove_namespaces(response[0].doc) }
        let(:mapped_doc2){ remove_namespaces(response[1].doc) }
        let(:mapped_xpaths1){ list_xpaths(mapped_doc1) }
        let(:mapped_xpaths2){ list_xpaths(mapped_doc2) }
        let(:fixture_doc1){ get_xml_fixture('core/nonHierarchicalRelationship1A.xml') }
        let(:fixture_xpaths1){ test_xpaths(fixture_doc1, handler.mapper.mappings) }
        let(:fixture_doc2){ get_xml_fixture('core/nonHierarchicalRelationship1B.xml') }
        let(:fixture_xpaths2){ test_xpaths(fixture_doc2, handler.mapper.mappings) }

        context 'with original data' do
          it 'sets response id field as expected' do
            expect(response[0].identifier).to eq('2020.1.107 TEST (collectionobjects) -> LOC2020.1.24 (movements)')
          end

          it 'does not map unexpected fields' do
            thisdiff = mapped_xpaths1 - fixture_xpaths1
            expect(thisdiff).to eq([])
          end

          it 'maps as expected' do
            fixture_xpaths1.each do |xpath|
              fixture_node = standardize_value(fixture_doc1.xpath(xpath).text)
              mapped_node = standardize_value(mapped_doc1.xpath(xpath).text)
              expect(mapped_node).to eq(fixture_node)
            end
          end
        end

        context 'with flipped data' do
          it 'sets response id field as expected' do
            expect(response[1].identifier).to eq('LOC2020.1.24 (movements) -> 2020.1.107 TEST (collectionobjects)')
          end

          it 'does not map unexpected fields' do
            thisdiff = mapped_xpaths2 - fixture_xpaths2
            expect(thisdiff).to eq([])
          end

          it 'maps as expected' do
            fixture_xpaths2.each do |xpath|
              fixture_node = standardize_value(fixture_doc2.xpath(xpath).text)
              mapped_node = standardize_value(mapped_doc2.xpath(xpath).text)
              expect(mapped_node).to eq(fixture_node)
            end
          end
        end
      end

      context 'when ID not found' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/nonHierarchicalRelationship2.json' }
        let(:mapped_doc1){ remove_namespaces(response[0].doc) }
        let(:mapped_doc2){ remove_namespaces(response[1].doc) }
        let(:mapped_xpaths1){ list_xpaths(mapped_doc1) }
        let(:mapped_xpaths2){ list_xpaths(mapped_doc2) }
        let(:fixture_doc1){ get_xml_fixture('core/nonHierarchicalRelationship2A.xml') }
        let(:fixture_xpaths1){ test_xpaths(fixture_doc1, handler.mapper.mappings) }
        let(:fixture_doc2){ get_xml_fixture('core/nonHierarchicalRelationship2B.xml') }
        let(:fixture_xpaths2){ test_xpaths(fixture_doc2, handler.mapper.mappings) }

        context 'with original data' do
          it 'sets response id field as expected' do
            expect(response[0].identifier).to eq('2020.1.107 TEST (collectionobjects) -> LOC MISSING (movements)')
          end

          it 'does not map unexpected fields' do
            thisdiff = mapped_xpaths1 - fixture_xpaths1
            expect(thisdiff).to eq([])
          end

          it 'maps as expected' do
            fixture_xpaths1.each do |xpath|
              fixture_node = standardize_value(fixture_doc1.xpath(xpath).text)
              mapped_node = standardize_value(mapped_doc1.xpath(xpath).text)
              expect(mapped_node).to eq(fixture_node)
            end
          end
        end

        context 'with flipped data' do
          it 'sets response id field as expected' do
            expect(response[1].identifier).to eq('LOC MISSING (movements) -> 2020.1.107 TEST (collectionobjects)')
          end

          it 'does not map unexpected fields' do
            thisdiff = mapped_xpaths2 - fixture_xpaths2
            expect(thisdiff).to eq([])
          end

          it 'maps as expected' do
            fixture_xpaths2.each do |xpath|
              fixture_node = standardize_value(fixture_doc2.xpath(xpath).text)
              mapped_node = standardize_value(mapped_doc2.xpath(xpath).text)
              expect(mapped_node).to eq(fixture_node)
            end
          end
        end
      end
    end

    context 'authority hierarchy record', services_call: true do
      let(:mapper) do
        get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_authorityhierarchy.json')
      end

      context 'with existing terms' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/authorityHierarchy1.json' }
        let(:fixturepath){ 'core/authorityHierarchy1.xml' }

        it 'sets response id field as expected' do
          expect(response.identifier).to eq('Cats > Siamese cats')
        end

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end

      context 'with a missing term' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/authorityHierarchy2.json' }
        let(:fixturepath){ 'core/authorityHierarchy2.xml' }

        it 'sets response id field as expected' do
          expect(response.identifier).to eq('Cats > Tuxedo cats')
        end

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'object hierarchy record', services_call: true do
      let(:mapper) do
        get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_objecthierarchy.json')
      end

      context 'with existing records' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/objectHierarchy1.json' }
        let(:fixturepath){ 'core/objectHierarchy1.xml' }

        it 'sets response id field as expected' do
          expect(response.identifier).to eq('2020.1.105 > 2020.1.1055')
        end

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end

      context 'with missing record' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/objectHierarchy2.json' }
        let(:fixturepath){ 'core/objectHierarchy2.xml' }

        it 'sets response id field as expected' do
          expect(response.identifier).to eq('2020.1.105 > MISSING')
        end

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'acquisition record', services_call: true do
      let(:mapper){ get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_acquisition.json') }

      context 'record 1' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/acquisition1.json' }
        let(:fixturepath){ 'core/acquisition1.xml' }

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'collectionobject record' do
      let(:mapper) do
        get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_collectionobject.json')
      end

      context 'record 1' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/collectionobject1.json' }
        let(:fixturepath){ 'core/collectionobject1.xml' }

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end

      context 'record 4 (bomb and %NULLVALUE% terms)' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/collectionobject4.json' }
        let(:fixture_doc){ get_xml_fixture('core/collectionobject4.xml', false) }

        it 'does not map unexpected fields' do
          expect(diff).to eq(['/document/collectionobjects_common/namedCollections/namedCollection/text()'])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end

      context 'record 5 (%NULLVALUE% term in repeating group)' do
        let(:config){ {delimiter: '|'} }
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/collectionobject5.json' }
        let(:fixturepath){ 'core/collectionobject5.xml' }

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'conditioncheck record', services_call: true do
      let(:mapper) do
        get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_conditioncheck.json')
      end

      context 'record 1' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/conditioncheck1.json' }
        let(:fixturepath){ 'core/conditioncheck1.xml' }

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'conservation record', services_call: true do
      let(:mapper) do
        get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_conservation.json')
      end

      context 'record 1' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/conservation1.json' }
        let(:fixturepath){ 'core/conservation1.xml' }

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'exhibition record', services_call: true do
      let(:mapper){ get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_exhibition.json') }

      context 'record 1' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/exhibition1.json' }
        let(:fixturepath){ 'core/exhibition1.xml' }

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'group record' do
      let(:mapper){ get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_group.json') }

      context 'record 1' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/group1.json' }
        let(:fixturepath){ 'core/group1.xml' }

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'intake record' do
      let(:mapper){ get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_intake.json') }

      context 'record 1' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/intake1.json' }
        let(:fixturepath){ 'core/intake1.xml' }

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'loanin record' do
      let(:mapper){ get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_loanin.json') }

      context 'record 1' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/loanin1.json' }
        let(:fixturepath){ 'core/loanin1.xml' }

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'loanout record' do
      let(:mapper){ get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_loanout.json') }

      context 'record 1' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/loanout1.json' }
        let(:fixturepath){ 'core/loanout1.xml' }

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'movement record' do
      let(:mapper){ get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_movement.json') }

      context 'record 1' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/movement1.json' }
        let(:fixturepath){ 'core/movement1.xml' }

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'media record' do
      let(:mapper){ get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_media.json') }

      context 'record 1' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/media1.json' }
        let(:fixturepath){ 'core/media1.xml' }

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'objectexit record' do
      let(:mapper){ get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_objectexit.json') }

      context 'record 1' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/objectexit1.json' }
        let(:fixturepath){ 'core/objectexit1.xml' }

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            # TODO: - why is this next clause here?
            next if xpath.start_with?('/document/objectexit_common/exitDateGroup')

            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'uoc record' do
      let(:mapper){ get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_uoc.json') }

      context 'record 1' do
        let(:hashpath){ 'spec/fixtures/files/datahashes/core/uoc1.json' }
        let(:fixturepath){ 'core/uoc1.xml' }

        it 'does not map unexpected fields' do
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end
  end
end

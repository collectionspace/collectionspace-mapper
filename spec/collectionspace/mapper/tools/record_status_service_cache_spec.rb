# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::RecordStatusServiceCache do
  let(:service){ CollectionSpace::Mapper::Tools::RecordStatusServiceCache.new(mapper) }
  let(:mapper) do
    CollectionSpace::Mapper::RecordMapper.new(mapper: get_json_record_mapper(mapper_path),
                                              termcache: core_cache,
                                              csidcache: core_csid_cache)
  end
  # @todo fix these tests so they are not on the now-private method
  describe '#call' do
    let(:result){ service.call(response) }
    
    context 'when mapper is for an authority' do
      let(:mapper_path) { 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_person-local.json' }
      let(:response){ double(:response, split_data: response_data) }

      context 'and result is found' do
        let(:response_data){ { 'termdisplayname'=>['John Doe'] } }

        it 'status = :existing' do
          expect(result[:status]).to eq(:existing)
        end
        it 'sets csid' do
          expect(result[:csid]).to eq('6369-4346-1059-9571')
        end
        it 'does not set uri' do
          expect(result[:uri]).to be nil
        end
        it 'sets refname' do
          refname = "urn:cspace:c.core.collectionspace.org:personauthorities:name(person):item:name(JohnDoe1416422840)'John Doe'"
          expect(result[:refname]).to eq(refname)
        end
      end

      context 'and no result is found' do
        let(:response_data){ { 'termdisplayname'=>['Chickweed Guineafowl'] } }
        it 'status = :new' do
          expect(result[:status]).to eq(:new)
        end
      end
    end

    context 'when mapper is for an object' do
      let(:mapper_path){ 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_collectionobject.json' }

      context 'when object is cached' do
        let(:response){ double(:response, identifier: 'Hierarchy Test 001') }
        it 'status = existing' do
          expect(result[:status]).to eq(:existing)
        end	
      end

      context 'when object is not cached' do
      let(:response){ double(:response, identifier: '2000.1') }
        it 'status = new' do
          expect(result[:status]).to eq(:new)
        end	
      end
    end

    context 'when mapper is for a procedure' do
      let(:mapper_path){ 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_acquisition.json' }

      context 'when cached' do
        let(:response){ double(:response, identifier: 'ACQ 123') }
        it 'status = existing' do
          expect(result[:status]).to eq(:existing)
        end	
      end

      context 'when not cached' do
        let(:response){ double(:response, identifier: 'foo.bar') }
        it 'status = new' do
          expect(result[:status]).to eq(:new)
        end	
      end
    end

    context 'when mapper is for a hierarchical relationship' do
      let(:mapper_path){ 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_objecthierarchy.json' }
      let(:response){ double(:response, combined_data: response_data) }
      
      context 'when cached' do
        let(:response_data) do
          {
            'relations_common'=>
              {'subjectCsid'=>['22706401-8328-4778-86fa'],
               'relationshipType'=>['hasBroader'],
               'objectCsid'=>['8e74756f-38f5-4dee-90d4']}
          }
        end

        it 'status = existing' do
          expect(result[:status]).to eq(:existing)
        end	
      end

      context 'when not cached' do
        let(:response_data) do
          {
            'relations_common'=>
              {'subjectCsid'=>['123'],
               'relationshipType'=>['hasBroader'],
               'objectCsid'=>['987']}
          }
        end
        
        it 'status = new' do
          expect(result[:status]).to eq(:new)
        end	
      end
    end

    context 'when mapper is for a non-hierarchical relationship' do
      let(:mapper_path){ 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_nonhierarchicalrelationship.json' }
      let(:response){ double(:response, combined_data: response_data) }
      
      context 'when cached' do
        let(:response_data) do
          {
            'relations_common'=>
              {'subjectCsid'=>['22706401-8328-4778-86fa'],
               'relationshipType'=>['affects'],
               'objectCsid'=>['8e74756f-38f5-4dee-90d4']}
          }
        end

        it 'status = existing' do
          expect(result[:status]).to eq(:existing)
        end	
      end

      context 'when not cached' do
        let(:response_data) do
          {
            'relations_common'=>
              {'subjectCsid'=>['123'],
               'relationshipType'=>['affects'],
               'objectCsid'=>['987']}
          }
        end
        
        it 'status = new' do
          expect(result[:status]).to eq(:new)
        end	
      end
    end
  end
end

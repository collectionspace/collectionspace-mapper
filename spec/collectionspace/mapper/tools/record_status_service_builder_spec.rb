# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::RecordStatusServiceBuilder do
  let(:client){ core_client }
  let(:config){ {} }
  
  describe '.call' do
    let(:mapper) do
      CollectionSpace::Mapper::RecordMapper.new(mapper: get_json_record_mapper(
        'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_group.json'
      ), termcache: core_cache, csidcache: 'foo', batchconfig: config)
    end
    let(:result){ described_class.call(client, mapper) }

    context 'when status_check_method = client' do
      let(:config){ {status_check_method: 'client'} }
      
      it 'raises returns RecordStatusServiceClient' do
        expect(result).to be_a(CollectionSpace::Mapper::Tools::RecordStatusServiceClient)
      end
    end

    context 'when status_check_method = cache' do
      let(:config){ {status_check_method: 'cache'} }
      it 'raises returns RecordStatusServiceCache' do
        expect(result).to be_a(CollectionSpace::Mapper::Tools::RecordStatusServiceCache)
      end
    end
  end

  describe '#get_value_for_record_status' do
    let(:klass){ described_class.new(client, mapper) }

    context 'with authority' do
      let(:mapper_config) do
        double(:config,
               service_type: 'authority',
               authority_type: 'personauthorities',
               authority_subtype: 'local'
              )
      end
      let(:mapper) do
        double(:mapper,
               service_type: CollectionSpace::Mapper::Authority,
               config: mapper_config)
      end
      let(:response_data) do
        {
          'termdisplayname'=>['Achillea millefolium', 'Achillea alpicola'],
          'termformatteddisplayname'=>['Achillea millefolium', 'Achillea alpicola'],
          'termqualifier'=>['qualifier', 'q2']
        }
      end
      let(:response){ double(:response, split_data: response_data) }
      let(:result){ klass.send(:get_value_for_record_status, response) }

      it 'returns expected value' do
        expect(result).to eq('Achillea millefolium')
      end
    end

    context 'with relation' do
      let(:mapper_config) do
        double(:config,
               service_type: 'relation',
               service_path: 'relations'
              )
      end

      let(:mapper) do
        double(:mapper,
               service_type: CollectionSpace::Mapper::Relationship,
               config: mapper_config)
      end

      let(:response_data) do
        {
          'relations_common'=>
            {'subjectCsid'=>['22706401-8328-4778-86fa'],
             'relationshipType'=>['affects'],
             'objectCsid'=>['8e74756f-38f5-4dee-90d4']}
        }
      end
      let(:response){ double(:response, combined_data: response_data) }
      let(:result){ klass.send(:get_value_for_record_status, response) }

      it 'returns expected value' do
        expected = {
          sub: '22706401-8328-4778-86fa',
          obj: '8e74756f-38f5-4dee-90d4',
          prd: 'affects'
        }
        expect(result).to eq(expected)
      end
    end

    context 'with object' do
      let(:mapper_config) do
        double(:config,
               service_type: 'collectionobject',
               service_path: 'collectionobjects'
              )
      end

      let(:mapper) do
        double(:mapper,
               service_type: CollectionSpace::Mapper::RecordMapper,
               config: mapper_config
              )
      end

      let(:response){ double(:response, identifier: '123') }
      let(:result){ klass.send(:get_value_for_record_status, response) }

      it 'returns expected value' do
        expect(result).to eq('123')
      end
    end
  end
end

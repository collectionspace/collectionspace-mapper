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
    context 'when mapper is for an authority' do
      let(:mapper_path) { 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_person-local.json' }
      let(:response_data){ { 'termdisplayname'=>['John Doe'] } }
      let(:response){ double(:response, split_data: response_data) }

      context 'and result is found' do
        let(:result){ service.call(response) }

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

      # context 'and no result is found' do
      #   it 'status = :new' do
      #     res = service.send(:lookup, 'Chickweed Guineafowl')
      #     expect(res[:status]).to eq(:new)
      #   end
      # end

      # context 'and multiple results found' do
      #   # if these tests fail, verify there are two person/local authority records for 'Inkpot Guineafowl'
      #   #   in core.dev
      #   # you may need to re-create them if they have been removed
      #   context 'with default config' do
      #     it 'raises error because we cannot know what to do with imported record' do
      #       expect do
      #         service.send(:lookup, 'Inkpot Guineafowl')
      #       end.to raise_error(CollectionSpace::Mapper::MultipleCsRecordsFoundError)
      #     end
      #   end

      #   context 'with multiple_recs_found = use first in batchconfig' do
      #     let(:json) do
      #       uri = 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_person-local.json'
      #       get_json_record_mapper(uri)
      #     end
      #     let(:mapper) do
      #       CollectionSpace::Mapper::RecordMapper.new(
      #         mapper: json,
      #         batchconfig: {multiple_recs_found: 'use_first'}
      #       )
      #     end
      #     let(:result){ service.send(:lookup, 'Inkpot Guineafowl').keys.any?(:multiple_recs_found) }
      #     it 'returns result with count of records found' do
      #       expect(result).to be true
      #     end
      #   end
      # end
    end

    # context 'when mapper is for an object' do
    #   let(:mapper) do
    #     CollectionSpace::Mapper::RecordMapper.new(mapper: get_json_record_mapper(
    #       'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_collectionobject.json'
    #     ), termcache: core_cache)
    #   end

    #   it 'works the same' do
    #     res = service.send(:lookup, '2000.1')
    #     expect(res[:status]).to eq(:existing)
    #   end
    # end

    # context 'when mapper is for a procedure' do
    #   let(:mapper) do
    #     CollectionSpace::Mapper::RecordMapper.new(mapper: get_json_record_mapper(
    #       'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_acquisition.json'
    #     ), termcache: core_cache)
    #   end

    #   it 'works the same' do
    #     res = service.send(:lookup, '2000.001')
    #     expect(res[:status]).to eq(:existing)
    #   end
    # end

    # context 'when mapper is for a relationship' do
    #   let(:mapper) do
    #     CollectionSpace::Mapper::RecordMapper.new(mapper: get_json_record_mapper(
    #       'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_objecthierarchy.json'
    #     ))
    #   end

    #   it 'works the same' do
    #     res = service.send(:lookup, {sub: '56c04f5f-32b9-4f1d-8a4b', obj: '6f0ce7b3-0130-444d-8633'})
    #     expect(res[:status]).to eq(:existing)
    #   end
    # end
  end
end


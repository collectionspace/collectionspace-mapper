# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::RecordStatusServiceBuilder do
  let(:client){ core_client }
  describe '.call' do
    let(:result){ described_class.call(client, mapper) }

    context 'when mapper does not have csidcache' do
      let(:mapper) do
        CS::Mapper::RecordMapper.new(mapper: get_json_record_mapper(
          'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_group.json'
        ), termcache: core_cache)
      end

      it 'raises returns RecordStatusServiceClient' do
        expect(result).to be_a(CS::Mapper::Tools::RecordStatusServiceClient)
      end
    end

    context 'when mapper has csidcache' do
      let(:mapper) do
        CS::Mapper::RecordMapper.new(mapper: get_json_record_mapper(
          'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_group.json'
        ), termcache: core_cache, csidcache: 'foo')
      end

      it 'raises returns RecordStatusServiceCache' do
        expect(result).to be_a(CS::Mapper::Tools::RecordStatusServiceCache)
      end
    end
  end
end

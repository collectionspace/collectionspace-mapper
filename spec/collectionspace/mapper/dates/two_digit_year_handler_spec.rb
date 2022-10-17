# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Dates::TwoDigitYearHandler do
  subject(:creator){ described_class.new(str, handler, handling) }
  let(:client){ anthro_client }
  let(:cache){ anthro_cache }
  let(:csid_cache){ anthro_csid_cache }
  let(:config){ CollectionSpace::Mapper::Config.new }
  let(:searcher) do
    CollectionSpace::Mapper::Searcher.new(client: client, config: config)
  end
  let(:handler) do
    CollectionSpace::Mapper::Dates::StructuredDateHandler.new(
      client: client,
      cache: cache,
      csid_cache: csid_cache,
      config: config,
      searcher: searcher
    )
    end
  let(:str){ '3-2-20' }

  describe '#mappable' do
    let(:result){ creator.mappable }

    context 'with literal' do
      let(:handling){ 'literal' }

      it 'returns expected' do
        expected = '0020-03-02T00:00:00.000Z'
        expect(result['dateEarliestScalarValue']).to eq(expected)
      end
    end

    context 'with coerce' do
      let(:handling){ 'coerce' }

      it 'returns expected' do
        expected = '2020-03-02T00:00:00.000Z'
        expect(result['dateEarliestScalarValue']).to eq(expected)
      end
    end

    context 'with foo' do
      let(:handling){ 'foo' }

      it 'returns expected' do
        expect(result['dateDisplayDate']).to eq(str)
        expect(result['scalarValuesComputed']).to eq('false')
      end
    end
  end
end

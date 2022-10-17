# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Dates::YearDateCreator do
  subject(:creator){ described_class.new(str, handler) }
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

  describe '#mappable' do
    let(:result){ creator.mappable }

    context 'with 2022' do
      let(:str){ '2022' }

      it 'returns expected' do
        expected = '2022-01-01T00:00:00.000Z'
        expect(result['dateEarliestScalarValue']).to eq(expected)
      end
    end

    context 'with foo' do
      let(:str){ 'foo' }

      it 'returns expected' do
        expect(result['dateDisplayDate']).to eq(str)
        expect(result['scalarValuesComputed']).to eq('false')
      end
    end
  end
end

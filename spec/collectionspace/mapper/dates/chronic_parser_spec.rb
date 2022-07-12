# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Dates::ChronicParser do
  subject(:parser){ described_class.new(str, handler) }
  let(:client){ anthro_client }
  let(:cache){ anthro_cache }
  let(:csid_cache){ anthro_csid_cache }
  let(:config){ CollectionSpace::Mapper::Config.new }
  let(:searcher) { CollectionSpace::Mapper::Searcher.new(client: client, config: config) }
  let(:handler){ CollectionSpace::Mapper::Dates::StructuredDateHandler.new(client: client, cache: cache, csid_cache: csid_cache, config: config, searcher: searcher) }

  describe '#mappable' do
    context 'with 2022-06-23' do
      let(:str){ '2022-06-23' }

      it 'returns expected' do
        expect(parser.mappable['dateEarliestScalarValue']).to eq('2022-06-23T00:00:00.000Z')
      end
    end

    context 'with 01-00-2000' do
      let(:str){ '01-00-2000' }

      it 'returns expected' do
        expect(parser.mappable['dateDisplayDate']).to eq(str)
        expect(parser.mappable['scalarValuesComputed']).to eq('false')
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Dates::StructuredDateHandler do
  let(:client){ anthro_client }
  let(:cache){ anthro_cache }
  let(:csid_cache){ anthro_csid_cache }
  let(:config){ CollectionSpace::Mapper::Config.new }
  let(:searcher) { CollectionSpace::Mapper::Searcher.new(client: client, config: config) }
  let(:handler){ described_class.new(client: client, cache: cache, csid_cache: csid_cache, config: config, searcher: searcher) }
  
  describe '#ce' do
    let(:result){ handler.ce }
    let(:refname){ "urn:cspace:#{domain}:vocabularies:name(dateera):item:name(ce)'CE'" }

    context 'when term is cached' do
      let(:domain){ 'c.anthro.collectionspace.org' }
      it 'returns expected refname' do
        expect(result).to eq(refname)
      end
    end

    context 'when term is not cached' do
      let(:domain){ 'anthro.collectionspace.org' }
      it 'returns expected refname' do
        [cache, csid_cache].each{ |c| c.remove_vocab_term('dateera', 'CE') }
        expect(result).to eq(refname)
      end
    end
  end
end

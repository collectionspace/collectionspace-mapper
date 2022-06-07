# frozen_string_literal: true

require 'spec_helper'

class TermClass
  attr_reader :cache, :client, :searcher
  attr_accessor :type, :subtype, :errors

  include CollectionSpace::Mapper::TermSearchable

  def initialize(cache, csid_cache, client, type, subtype)
    @cache = cache
    @csid_cache = csid_cache
    @client = client
    @type = type
    @subtype = subtype
    @errors = []
    @searcher = CollectionSpace::Mapper::Searcher.new(client: client)
  end
end

RSpec.describe CollectionSpace::Mapper::TermSearchable do
  let(:cache){ core_cache }
  let(:csid_cache){ core_csid_cache }
  let(:termtype){ 'conceptauthorities' }
  let(:termsubtype){ 'concept' }
  let(:term){ TermClass.new(cache, csid_cache, core_client, termtype, termsubtype) }

  describe '#in_cache?' do
    let(:result){ term.in_cache?(val) }
    context 'when not in cache' do
      let(:val){ 'Tiresias' }
      it 'returns false' do
        expect(result).to be false
      end
    end

    context 'when in cache' do
      let(:val){ 'Test' }
      it 'returns true' do
        expect(result).to be true
      end
    end

    context 'when captitalized form is in cache' do
      let(:val){ 'test' }
      it 'returns true' do
        expect(result).to be true
      end
    end
  end

  describe '#cached_as_unknown?' do
    let(:result){ term.cached_as_unknown?(val) }
    let(:val){ 'blahblahblah' }

    context 'when not cached as unknown value' do
      it 'returns false' do
        expect(result).to be false
      end
    end

    context 'when cached as unknown value' do
      it 'returns true' do
        cache.put('unknownvalue', "#{termtype}/#{termsubtype}", val, nil)
        expect(result).to be true
      end
    end
  end

  describe '#cached_term' do
    let(:result){ term.cached_term(val) }
    context 'when not in cache' do
      let(:val){ 'Tiresias' }
      it 'returns nil' do
        expect(result).to be_nil
      end
    end

    context 'when in cache' do
      let(:val){ 'Test' }
      it 'returns refname urn' do
        expected = "urn:cspace:c.core.collectionspace.org:conceptauthorities:name(concept):item:name(Test1599650854716)'Test'"
        expect(result).to eq(expected)
      end
    end

    context 'when capitalized form is in cache' do
      let(:val){ 'test' }
      it 'returns refname urn' do
        expected = "urn:cspace:c.core.collectionspace.org:conceptauthorities:name(concept):item:name(Test1599650854716)'Test'"
        expect(result).to eq(expected)
      end
    end
  end

  describe '#searched_term' do
    let(:termtype){ 'vocabularies' }
    let(:termsubtype){ 'publishto' }
    let(:result){ term.searched_term(val, :refname, termtype, termsubtype) }

    context 'when val exists in instance' do
      let(:val){ 'All' }
      it 'returns refname urn' do
        expected = "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(all)'All'"
        expect(result).to eq(expected)
      end
    end

    context 'when case-swapped val exists in instance' do
      let(:val){ 'all' }
      it 'returns refname urn' do
        expected = "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(all)'All'"
        expect(result).to eq(expected)
      end
    end
  end

  # also covers lookup_obj_csid
  describe '#obj_csid' do
    let(:type){ 'collectionobjects' }
    let(:result){ term.obj_csid(objnum, type) }
    context 'when in cache' do
      let(:objnum){ 'Hierarchy Test 001' }

      it 'returns csid' do
        expect(result).to eq('7976-7265-3715-6363')
      end
    end

    context 'when not in cache' do
      let(:objnum){ 'QA TEST 001' }
      it 'returns csid' do
        expect(result).to eq('56c04f5f-32b9-4f1d-8a4b')
      end
    end
  end

  describe '#term_csid' do
    let(:result){ term.term_csid(val) }
    context 'when in cache' do
      let(:val){ 'Sample Concept 1' }
      it 'returns csid' do
        # it 'returns csid', :skip => 'does not cause mapping to fail, so we live with technical incorrectness for now' do
        expect(result).to eq('3736-2250-1869-4155')
      end
    end

    context 'when not in cache' do
      let(:val){ 'QA TEST Concept 2' }
      it 'returns csid' do
        expect(result).to eq('8a76c4d7-d66d-451c-abee')
      end
    end
  end
end

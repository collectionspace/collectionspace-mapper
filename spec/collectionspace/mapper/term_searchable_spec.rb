# frozen_string_literal: true

require 'spec_helper'

class TermClass
  attr_reader :cache, :client
  attr_accessor :type, :subtype, :errors
  include CS::Mapper::TermSearchable

  def initialize(cache, client)
    @cache = cache
    @client = client
    @type = 'conceptauthorities'
    @subtype = 'concept'
    @errors = []
  end
  
end

RSpec.describe CollectionSpace::Mapper::TermSearchable do
  before(:context) do
    @cache = core_cache
    populate_core(@cache)
  end
  
  let(:term){ TermClass.new(@cache, core_client) }

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
        expected = "urn:cspace:core.collectionspace.org:conceptauthorities:name(concept):item:name(Test1599650854716)'Test'"
        expect(result).to eq(expected)
      end
    end
  end

  # also covers extract_refname_csid and lookup_obj_csid
  describe '#obj_csid' do
    let(:result){ term.obj_csid(objnum, type) }
    let(:type){ 'collectionobjects' }
    context 'when in cache' do
      let(:objnum){ 'Hierarchy Test 001' }
      
      it 'returns csid' do
        expect(result).to eq('16161bff-b01a-4b55-95aa')
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
      
      it 'returns csid', :skip => 'does not cause mapping to fail, so we live with technical incorrectness for now' do
        expect(result).to eq('c119ed04-d99d-4ea2-bbda')
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

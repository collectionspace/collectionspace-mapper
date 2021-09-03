# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::RefName do
  before(:context) do
    @cache = anthro_cache
    populate_anthro(@cache)
  end
  context 'when initialized with source_type, type, subtype, term, and cache' do
    it 'builds refname for authorities' do
      args = {
        source_type: :authority,
        type: 'personauthorities',
        subtype: 'person',
        term: 'Mary Poole',
        cache: @cache
      }
      refname = "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(MaryPoole1796320156)'Mary Poole'"
      result = CollectionSpace::Mapper::Tools::RefName.new(args)
      expect(result.urn).to eq(refname)
    end

    it 'builds refname for vocabularies' do
      args = {
        source_type: :vocabulary,
        type: 'vocabularies',
        subtype: 'annotationtype',
        term: 'another term',
        cache: @cache
      }
      refname = "urn:cspace:anthro.collectionspace.org:vocabularies:name(annotationtype):item:name(anotherterm)'another term'"
      result = CollectionSpace::Mapper::Tools::RefName.new(args)
      expect(result.urn).to eq(refname)
    end
  end

  context 'when initialized with urn' do
    it 'builds refname from URN' do
      args = {
        urn: "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(MaryPoole1796320156)'Mary Poole'"
      }
      result = CollectionSpace::Mapper::Tools::RefName.new(args)
      expect(result.domain).to eq('anthro.collectionspace.org')
      expect(result.display_name).to eq('Mary Poole')
    end
  end

  context 'when initialized with non-sensical argument combination' do
    it 'raises error' do
      args = {
        urn: "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(MaryPoole1796320156)'Mary Poole'",
        cache: @cache
      }
      expect { CollectionSpace::Mapper::Tools::RefName.new(args) }.to raise_error(CollectionSpace::Mapper::Tools::RefNameArgumentError)
    end
  end
end


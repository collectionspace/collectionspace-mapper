# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::RefName do
  before(:all) do
    @cache = anthro_cache
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
    context 'with urn for authority term' do
      it 'builds refname from URN' do
        args = {
          urn: "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(MaryPoole1796320156)'Mary Poole'"
        }
        result = CollectionSpace::Mapper::Tools::RefName.new(args)
        expect(result.domain).to eq('anthro.collectionspace.org')
        expect(result.display_name).to eq('Mary Poole')
      end
    end

    context 'with urn for collectionobject' do
      it 'builds refname from URN' do
        args = {
          urn: "urn:cspace:core.collectionspace.org:collectionobjects:id(9010870e-e323-4beb-b065)'2020.1.1055'"
        }
        result = CollectionSpace::Mapper::Tools::RefName.new(args)
        expect(result.domain).to eq('core.collectionspace.org')
        expect(result.type).to eq('collectionobjects')
        expect(result.subtype).to be_nil
        expect(result.identifier).to eq('9010870e-e323-4beb-b065')
        expect(result.display_name).to eq('2020.1.1055')
      end
    end

    context 'with urn for movement' do
      it 'builds refname from URN' do
        args = {
          urn: "urn:cspace:core.collectionspace.org:movements:id(8e74756f-38f5-4dee-90d4)"
        }
        result = CollectionSpace::Mapper::Tools::RefName.new(args)
        expect(result.domain).to eq('core.collectionspace.org')
        expect(result.type).to eq('movements')
        expect(result.subtype).to be_nil
        expect(result.identifier).to eq('8e74756f-38f5-4dee-90d4')
        expect(result.display_name).to eq('')
      end
    end

    context 'with unparseable URN' do
      it 'raises error' do
        args = {
          urn: "urn:cspace:core.collectionspace.org:weird"
        }
        expect{ CollectionSpace::Mapper::Tools::RefName.new(args) }.to raise_error(CollectionSpace::Mapper::Tools::UnparseableUrnError)
      end
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


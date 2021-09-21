# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::ValueTransformer do
  before(:all) do
   client = anthro_client
   cache = anthro_cache
   mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_collectionobject.json')
   handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: mapper,
                                                      client: client,
                                                      cache: cache,
                                                      config: {})
   @prepper = CollectionSpace::Mapper::DataPrepper.new({}, handler)
 end

  context 'when vocabulary' do
    context 'and vocabulary is behrensmeyer number' do
      it 'returns transformed value for retrieving refname' do
        value = '0'
        transforms = {vocabulary: 'behrensmeyer', special: %w[behrensmeyer_translate]}
        res = CollectionSpace::Mapper::ValueTransformer.new(value, transforms, @prepper).result
        ex = '0 - no cracking or flaking on bone surface'
        expect(res).to eq(ex)
      end
    end

    context 'and replacement transformation specified' do
      context 'and term given = Adolescent 26 - 75%' do
        it 'returns replaced value for retriefing refname' do
          value = 'Adolescent 26 - 75%'
          transforms = {vocabulary: 'agerange', special: %w[downcase_value],
                        replacements: [
                          {find: ' - ', replace: '-', type: :plain}
                        ]
                       }
          res = CollectionSpace::Mapper::ValueTransformer.new(value, transforms, @prepper).result
          ex = 'adolescent 26-75%'
          expect(res).to eq(ex)
        end
      end
    end
  end

  context 'when replacements' do
    it 'does replacements' do
      value = 'rice plant'
      transforms = {
        replacements: [
          {find: '[aeiou]', replace: 'y', type: :regexp},
          {find: ' ', replace: '%%', type: :plain},
          {find: '(\w)%%(\w)', replace: '\1 \2', type: :regexp}
        ]
      }
      res = CollectionSpace::Mapper::ValueTransformer.new(value, transforms, @prepper).result
      expect(res).to eq('rycy plynt')
    end
  end
end




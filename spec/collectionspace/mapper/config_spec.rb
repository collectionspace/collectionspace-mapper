# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Config do
  let(:configstr) { '{
                       "delimiter": ";",
                       "subgroup_delimiter": "^^",
                       "response_mode": "verbose",
                       "force_defaults": false,
                       "check_record_status": true,
                       "check_terms": true,
                       "date_format": "month day year",
                       "two_digit_year_handling": "convert to four digit",
                       "transforms": {
                         "collection": {
                           "special": [
                             "downcase_value"
                           ],
                           "replacements": [{
                             "find": " ",
                             "replace": "-",
                             "type": "plain"
                           }]
                         }
                       },
                       "default_values": {
                         "publishTo": "DPLA;Omeka",
                         "collection": "library-collection"
                       }
                     }'
  }
  let(:with_string){ described_class.new(config: configstr) }
  let(:confighash){ JSON.parse(configstr) }
  let(:with_hash){ described_class.new(config: confighash) }
  let(:with_nothing){ described_class.new }
  let(:with_array){ described_class.new(config: [2, 3]) }
  let(:expected_hash){
 {delimiter: ';', subgroup_delimiter: '^^', response_mode: 'verbose', force_defaults: false,
  check_record_status: true, check_terms: true, date_format: 'month day year', two_digit_year_handling: 'convert to four digit', transforms: {'collection' => {special: ['downcase_value'], replacements: [{find: ' ', replace: '-', type: 'plain'}]}}, default_values: {'publishto' => 'DPLA;Omeka', 'collection' => 'library-collection'}} }
  let(:invalid_response){ {response_mode: 'mouthy'} }
  let(:with_invalid_response){ described_class.new(config: invalid_response) }

  context 'when initialized with JSON string' do
    it 'is created' do
      expect(with_string).to be_a(described_class)
    end
  end

  context 'when initialized with Hash' do
    it 'is created' do
      expect(with_hash).to be_a(described_class)
    end
  end

  context 'when initialized with no config specified' do
    it 'is created' do
      expect(with_nothing).to be_a(described_class)
    end
    it 'uses default config' do
      expected = described_class::DEFAULT_CONFIG.clone
      expected[:default_values] = {}
      expect(with_nothing.hash).to eq(expected)
    end
  end

  context 'when initialized with Array' do
    it 'raises error' do
      expect{ with_array }.to raise_error(described_class::UnhandledConfigFormatError)
    end
  end

  context 'when initialized with invalid response mode' do
    it 'uses default response value' do
      expect(with_invalid_response.response_mode).to eq(described_class::DEFAULT_CONFIG[:response_mode])
    end
  end

  context 'when initialized without required config attributes' do
    it 'use default response values' do
      res = [with_invalid_response.delimiter, with_invalid_response.subgroup_delimiter]
      expected = [described_class::DEFAULT_CONFIG[:delimiter],
                  described_class::DEFAULT_CONFIG[:subgroup_delimiter]]
      expect(res).to eq(expected)
    end
  end

  context 'when initialized as object hierarchy' do
    it 'sets special defaults' do
      config = described_class.new(record_type: CS::Mapper::ObjectHierarchy)
      expect(config.default_values.length).to eq(3)
    end
  end

  context 'when initialized as authority hierarchy' do
    it 'sets special defaults' do
      config = described_class.new(record_type: CS::Mapper::AuthorityHierarchy)
      expect(config.default_values['relationshiptype']).to eq('hasBroader')
    end
  end

  context 'when initialized as non-hierarchical relationship' do
    it 'sets special defaults' do
      config = described_class.new(record_type: CS::Mapper::NonHierarchicalRelationship)
      expect(config.default_values['relationshiptype']).to eq('affects')
    end
  end

  describe '#hash' do
    it 'returns expected hash' do
      result = described_class.new(config: configstr).hash
      expect(result).to eq(expected_hash)
    end
  end

  # move functionality from handler
  # describe '#merge_config_transforms' do
  #   context 'anthro profile' do
  #     context 'collectionobject record' do
  #       before(:all) do
  #         @config = CollectionSpace::Mapper::Config.new({
  #           transforms: {
  #             'Collection' => {
  #               special: %w[downcase_value],
  #               replacements: [
  #                 { find: ' ', replace: '-', type: :plain }
  #               ]
  #             }
  #           }
  #         })
  #       end
  #       context 'collection data field' do
  #         it 'merges data field specific transforms' do
  #           handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @anthro_object_mapper,
  #                                                              client: @anthro_client,
  #                                                              cache: @anthro_cache,
  #                                                              config: @config)
  #           fieldmap = handler.mapper.mappings.select{ |mapping| mapping.fieldname == 'collection' }.first
  #           xforms = {
  #             special: %w[downcase_value],
  #             replacements: [
  #               { find: ' ', replace: '-', type: :plain }
  #             ]
  #           }
  #           expect(fieldmap.transforms).to eq(xforms)
  #         end
  #       end
  #     end
  #   end
  # end
end



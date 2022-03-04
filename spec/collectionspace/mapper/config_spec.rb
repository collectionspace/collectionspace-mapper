# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Config do
  let(:config){ described_class.new(opts) }
  let(:configstr) do
    '{
                       "delimiter": ";",
                       "subgroup_delimiter": "^^",
                       "response_mode": "verbose",
                       "force_defaults": false,
                       "check_record_status": true,
                       "status_check_method": "client",
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
  end

  let(:confighash){ JSON.parse(configstr) }

  context 'when initialized with JSON string' do
    let(:opts){ {config: configstr} }
    
    it 'is created' do
      expect(config).to be_a(described_class)
    end
  end

  context 'when initialized with Hash' do
    let(:opts){ {config: confighash} }
    
    it 'is created' do
      expect(config).to be_a(described_class)
    end
  end

  context 'when initialized with no config specified' do
    let(:config){ described_class.new }
    it 'is created' do
      expect(config).to be_a(described_class)
    end
    it 'uses default config' do
      expected = described_class::DEFAULT_CONFIG.clone
      expected[:default_values] = {}
      expect(config.hash).to eq(expected)
    end
  end

  context 'when initialized with Array' do
    let(:opts){ {config: [2, 3]} }
    it 'raises error' do
      expect{ config }.to raise_error(described_class::UnhandledConfigFormatError)
    end
  end

  context 'when initialized with invalid response mode' do
    let(:opts){ {config: {response_mode: 'mouthy'}} }
    it 'uses default response value' do
      expect(config.response_mode).to eq(described_class::DEFAULT_CONFIG[:response_mode])
    end
  end

  context 'when initialized with invalid status_check_method' do
    let(:opts){ {config: {status_check_method: 'chaos'}} }
    it 'uses default response value' do
      expect(config.status_check_method).to eq(described_class::DEFAULT_CONFIG[:status_check_method])
    end
  end

  context 'when initialized without required config attribute' do
    let(:opts){ {config: {subgroup_delimiter: '|||'} } }
    it 'use default response value' do
      expect(config.delimiter).to eq(described_class::DEFAULT_CONFIG[:delimiter])
    end
  end

  context 'when initialized as object hierarchy' do
    let(:opts){ {record_type: 'objecthierarchy'} }
    it 'sets special defaults' do
      expect(config.default_values.length).to eq(3)
    end
  end

  context 'when initialized as authority hierarchy' do
    let(:opts){ {record_type: 'authorityhierarchy'} }
    it 'sets special defaults' do
      expect(config.default_values['relationshiptype']).to eq('hasBroader')
    end
  end

  context 'when initialized as non-hierarchical relationship' do
    let(:opts){ {record_type: 'nonhierarchicalrelationship'} }
    it 'sets special defaults' do
      expect(config.default_values['relationshiptype']).to eq('affects')
    end
  end

  describe '#hash' do
    let(:expected_hash) do
      {delimiter: ';', subgroup_delimiter: '^^', response_mode: 'verbose', strip_id_values: true,
       multiple_recs_found: 'fail', force_defaults: false, check_record_status: true, status_check_method: 'client', check_terms: true, date_format: 'month day year', two_digit_year_handling: 'convert to four digit', transforms: {'collection' => {special: ['downcase_value'], replacements: [{find: ' ', replace: '-', type: 'plain'}]}}, default_values: {'publishto' => 'DPLA;Omeka', 'collection' => 'library-collection'}}
    end

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

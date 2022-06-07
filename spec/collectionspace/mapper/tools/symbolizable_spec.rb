# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::Symbolizable do
  let(:config) do
    JSON.parse('{
                               "delimiter": ";",
                               "subgroup_delimiter": "^^",
                               "response_mode": "verbose",
                               "force_defaults": false,
                               "check_record_status": true,
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
                             }')
  end

  let(:symconfig){ CollectionSpace::Mapper::Tools::Symbolizable.symbolize(config) }
  describe '#symbolize' do
    it 'turns hash keys into symbols' do
      expected = %i[delimiter subgroup_delimiter response_mode force_defaults check_record_status
                    date_format two_digit_year_handling transforms default_values]
      expect(symconfig.keys).to eq(expected)
    end
  end

  describe '#symbolize_transforms' do
    let(:transforms){ symconfig[:transforms] }
    let(:expected) do
      {'collection' => {special: ['downcase_value'],
                        replacements: [{find: ' ', replace: '-', type: 'plain'}]}}
    end
    it 'transforms as expected' do
      expect(CollectionSpace::Mapper::Tools::Symbolizable.symbolize_transforms(transforms)).to eq(expected)
    end
  end
end

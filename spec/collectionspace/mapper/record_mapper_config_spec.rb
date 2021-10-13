# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::RecordMapperConfig do
  let(:hash) { {'ns_uri' => {
    'collectionobjects_common' => 'http://collectionspace.org/services/collectionobject',
    'collectionobjects_anthro' => 'http://collectionspace.org/services/collectionobject/domain/anthro',
    'collectionobjects_annotation' => 'http://collectionspace.org/services/collectionobject/domain/annotation',
    'collectionobjects_culturalcare' => 'http://collectionspace.org/services/collectionobject/domain/collectionobject',
    'collectionobjects_nagpra' => 'http://collectionspace.org/services/collectionobject/domain/nagpra',
    'collectionobjects_naturalhistory_extension' => 'http://collectionspace.org/services/collectionobject/domain/naturalhistory_extension',
    'somethingelse_common' => 'http://collectionspace.org/services/collectionobject/domain/nagpra'
  }} }
  let(:config){ described_class.new(hash) }
  describe '#namespaces' do
    it 'returns Array of namespace names' do
      expect(config.namespaces.sort).to eq(hash['ns_uri'].keys.sort)
    end
  end

  describe '#common_namespace' do
    it 'return first namespace with "_common" suffix' do
      expect(config.common_namespace).to eq('collectionobjects_common')
    end
  end
end

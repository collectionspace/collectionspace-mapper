# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::VocabularyTerms::Handler do
  subject(:handler){ described_class.new(client: client) }
  let(:client){ core_client }

  describe '#add_term' do
    let(:result){ handler.add_term(vocab: vocab, term: term) }

    context 'with existing term' do
      let(:vocab){ 'Annotation Type' }
      let(:term){ 'nomenclature' }
      it 'returns Failure' do
        expect(result).to be_a(Dry::Monads::Failure)
        failmsg = 'annotationtype/nomenclature already exists'
        expect(result.failure).to eq(failmsg)
      end
    end

    context 'with new term' do
      let(:vocab){ 'Annotation Type' }
      let(:term){ 'Credit line' }
      it 'returns Failure' do
        expect(result).to be_a(Dry::Monads::Success)
        client.delete(result.value!)
      end
    end
  end
end

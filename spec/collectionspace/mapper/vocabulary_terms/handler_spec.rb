# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::VocabularyTerms::Handler,
  skip: "test after splitting handlers" do
  subject(:handler) { described_class.new }
  before{ setup }
  after{ CollectionSpace::Mapper.reset_config }

  describe "#add_term" do
    let(:result) { handler.add_term(vocab: vocab, term: term) }

    context "with existing term", vcr: "vocab_terms_handler_existing" do
      let(:vocab) { "Annotation Type" }
      let(:term) { "nomenclature" }
      it "returns Failure" do
        expect(result).to be_a(Dry::Monads::Failure)
        failmsg = "annotationtype/nomenclature already exists"
        expect(result.failure).to eq(failmsg)
      end
    end

    context "with new term", vcr: "vocab_terms_handler_new" do
      let(:vocab) { "Annotation Type" }
      let(:term) { "Credit line" }
      it "returns Success" do
        expect(result).to be_a(Dry::Monads::Success)
        CollectionSpace::Mapper.client.delete(result.value!)
      end
    end
  end
end

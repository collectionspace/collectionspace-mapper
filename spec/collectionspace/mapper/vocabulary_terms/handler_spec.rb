# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::VocabularyTerms::Handler do
  subject(:handler) { described_class.new(client: client) }

  let(:client) { core_client }
  let(:opt_fields) { nil }

  describe "#add_term" do
    let(:result) do
      handler.add_term(vocab: vocab, term: term, opt_fields: opt_fields)
    end

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
      let(:term) { "New annotation type" }
      let(:opt_fields) { {"description" => "a"} }
      it "returns Success" do
        expect(result).to be_a(Dry::Monads::Success)
        parsed = client.get(result.value!).parsed
        expect(parsed.dig("document", "vocabularyitems_common", "description"))
          .to eq("a")
        client.delete(result.value!)
      end
    end
  end

  describe "#update_term" do
    let(:result) do
      handler.update_term(vocab: vocab, term: term, opt_fields: opt_fields)
    end

    context "when adding a field to an existing term",
      vcr: "vocab_terms_handler_existing_add_field" do
      let(:vocab) { "Annotation Type" }
      let(:term) { "nomenclature" }
      let(:opt_fields) { {"description" => "a"} }
      it "returns Success" do
        expect(result).to be_a(Dry::Monads::Success)
        parsed = client.get(result.value!).parsed
        expect(parsed.dig("document", "vocabularyitems_common", "description"))
          .to eq("a")
        handler.update_term(
          vocab: vocab, term: term, opt_fields: {"description" => "💣"}
        )
        cleaned = client.get(result.value!).parsed
        expect(cleaned.dig("document", "vocabularyitems_common", "description"))
          .to be_nil
      end
    end

    context "when changing display name of existing term",
      vcr: "vocab_terms_handler_existing_change_term" do
        let(:vocab) { "Annotation Type" }
        let(:term) { "nomenclature" }
        let(:opt_fields) { {"displayName" => "new nomenclature"} }
        it "returns Success" do
          expect(result).to be_a(Dry::Monads::Success)
          parsed = client.get(result.value!).parsed
          expect(parsed.dig("document", "vocabularyitems_common",
            "displayName"))
            .to eq("new nomenclature")
          handler.update_term(
            vocab: vocab, term: "new nomenclature",
            opt_fields: {"displayName" => "nomenclature"}
          )
          cleaned = client.get(result.value!).parsed
          expect(cleaned.dig("document", "vocabularyitems_common",
            "displayName"))
            .to eq("nomenclature")
        end
      end

    context "with new term", vcr: "vocab_terms_handler_update_new" do
      let(:vocab) { "Annotation Type" }
      let(:term) { "nope" }
      it "returns Failure" do
        expect(result).to be_a(Dry::Monads::Failure)
        failmsg = "The term \"nope\" does not exist in Annotation Type"
        expect(result.failure).to eq(failmsg)
      end
    end
  end
end

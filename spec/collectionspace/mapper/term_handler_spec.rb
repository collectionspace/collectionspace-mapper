# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::TermHandler do
  subject(:th) do
    CollectionSpace::Mapper::TermHandler.new(
      mapping: colmapping,
      data: data
    )
  end

  before do
    setup_handler(
      mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
        "core_6-1-0_collectionobject.json"
    )
  end
  after{ CollectionSpace::Mapper.reset_config }

  let(:colmapping) do
    CollectionSpace::Mapper.recordmapper.mappings.lookup(colname)
  end

  describe "#result" do
    context "titletranslationlanguage (vocabulary, field subgroup)" do
      let(:colname) { "titleTranslationLanguage" }
      let(:data) {
        [["%NULLVALUE%", "Swahili"], %w[Klingon Spanish],
         [CollectionSpace::Mapper.bomb]]
      }

      it "result is the transformed value for mapping",
        vcr: "term_handler_result_titletranslationlanguage" do
          expected = [
            ["",
             "urn:cspace:c.core.collectionspace.org:vocabularies:name"\
               "(languages):item:name(swa)'Swahili'"],
            ["",
             "urn:cspace:c.core.collectionspace.org:vocabularies:name"\
               "(languages):item:name(spa)'Spanish'"],
            [CollectionSpace::Mapper.bomb]
          ]
          expect(th.result).to eq(expected)
          expect(th.errors.length).to eq(1)
        end
    end

    context "reference (authority, field group)" do
      let(:colname) { "referenceLocal" }
      let(:data) { ["Arthur", "Harding", "%NULLVALUE%"] }

      it "result is the transformed value for mapping" do
        expected = [
          "urn:cspace:c.core.collectionspace.org:citationauthorities:name"\
            "(citation):item:name(Arthur62605812848)'Arthur'",
          "urn:cspace:c.core.collectionspace.org:citationauthorities:name"\
            "(citation):item:name(Harding2510592089)'Harding'",
          ""
        ]
        expect(th.result).to eq(expected)
      end
      it "all values are refnames" do
        chk = th.result.flatten.select { |v| v.start_with?("urn:") }
        expect(chk.length).to eq(2)
      end
    end
  end

  describe "#terms" do
    let(:terms) { th.terms }

    context "titletranslationlanguage (vocabulary, field subgroup)" do
      let(:colname) { "titleTranslationLanguage" }
      let(:data) {
        [["%NULLVALUE%", "Swahili"], %w[Sanza Spanish],
         [CollectionSpace::Mapper.bomb]]
      }

      context "when new term (Sanza) is initially encountered" do
        it "returns terms as expected",
          vcr: "term_handler_terms_sanza" do
            found = terms.select { |h| h[:found] }
            not_found = terms.select { |h| !h[:found] }
            expect(terms.length).to eq(3)
            expect(found.length).to eq(2)
            expect(not_found.first[:refname].urn).to eq(
              "vocabularies|||languages|||Sanza"
            )
          end
      end

      context "when new term is subsequently encountered" do
        it "the term is still treated as not found",
          vcr: "term_handler_terms_sanza" do
            CollectionSpace::Mapper::TermHandler.new(
              mapping: colmapping,
              data: data
            )

            chk = terms.select { |h| h[:found] }
            expect(chk.length).to eq(2)
          end
      end
    end

    context "reference (authority, field group)" do
      let(:colname) { "referenceLocal" }
      let(:data) {
        ["Reference 3", "Reference 3", "Reference 4", "%NULLVALUE%"]
      }

      context "when new term (Reference 3) is initially encountered" do
        it "contains a term Hash for each value",
          vcr: "term_handler_terms_ref_multi_used" do
            found = th.terms.select { |h| h[:found] }
            not_found = th.terms.select { |h| !h[:found] }
            expect(terms.length).to eq(3)
            expect(found.length).to eq(0)
            expect(not_found.first[:refname].display_name).to eq("Reference 3")
          end
      end
    end
  end
end

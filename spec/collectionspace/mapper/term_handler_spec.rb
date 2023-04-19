# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::TermHandler do
  subject(:th) do
    described_class.new(
      mapping: mapping,
      data: data,
      handler: handler,
      response: response
    )
  end

  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper
    )
  end
  let(:profile){ "core" }
  let(:mapper){ "core_6-1-0_collectionobject" }
  let(:mapping) do
    handler.record.mappings.lookup(colname)
  end
  let(:response) do
    CollectionSpace::Mapper::Response.new(
      {colname=>"foo"},
      handler
    )
  end

  describe ".new", vcr: "core_domain_check" do
    let(:result){ th; response.transformed_data[colname.downcase] }
    let(:errs){ response.errors }

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
            expect(result).to eq(expected)
            err = errs.find do
              |error| error.is_a?(Hash) &&
                error[:category] == :no_records_found_for_term
            end
            expect(err[:value]).to eq("Klingon")
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
        expect(result).to eq(expected)
      end
    end
  end

  describe "#terms" do
    let(:terms) { th; response.terms }

    context "titletranslationlanguage (vocabulary, field subgroup)" do
      let(:colname) { "titleTranslationLanguage" }
      let(:data) {
        [["%NULLVALUE%", "Swahili"], %w[Sanza Spanish],
         [CollectionSpace::Mapper.bomb]]
      }

      context "when new term (Sanza) is initially encountered" do
        it "returns terms as expected",
          vcr: "term_handler_terms_sanza" do
            found = terms.select { |h| h.found? }
            not_found = terms.reject { |h| h.found? }
            expect(terms.length).to eq(3)
            expect(found.length).to eq(2)
            expect(not_found.first.urn).to eq(
              "vocabularies|||languages|||Sanza"
            )
          end
      end

      context "when new term is subsequently encountered" do
        it "the term is still treated as not found",
          vcr: "term_handler_terms_sanza" do
            new_resp = CollectionSpace::Mapper::Response.new(
              {colname=>"bar"},
              handler
            )
            new_th = CollectionSpace::Mapper::TermHandler.new(
              mapping: mapping,
              data: data,
              handler: handler,
              response: new_resp
            )

            chk = new_resp.terms.select { |h| !h.found? }
            expect(chk.length).to eq(1)
            expect(chk.first.urn).to eq(
              "vocabularies|||languages|||Sanza"
            )
          end
      end
    end

    context "reference (authority, field group)" do
      let(:colname) { "referenceLocal" }
      let(:data) {
        ["Reference 3", "Reference 3", "Reference 4", "%NULLVALUE%"]
      }

      context "when new term (Reference 3) is initially encountered" do
        it "contains UsedTerm object for each value",
          vcr: "term_handler_terms_ref_multi_used" do
            th
            found = response.terms.select { |h| h.found? }
            not_found = response.terms.reject { |h| h.found? }
            expect(response.terms.length).to eq(3)
            expect(found.length).to eq(0)
            expect(not_found[0].display_name).to eq("Reference 3")
          end
      end
    end
  end
end

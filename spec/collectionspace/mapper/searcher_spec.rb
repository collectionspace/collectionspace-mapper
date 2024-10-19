# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Searcher do
  subject(:searcher) { handler.searcher }

  let(:handler) do
    setup_handler(
      mapper: mapper,
      config: config
    )
  end
  let(:mapper) { "core_6-1-0_group" }

  describe "#.call", vcr: "core_domain_check" do
    let(:result) { searcher.call(**args) }
    let(:args) { {value: value, type: "vocabularies", subtype: "publishto"} }

    context "when search_if_not_cached = true", vcr: "searcher_search" do
      let(:config) { {} }
      let(:value) { "All" }

      it "returns expected hash" do
        expect(result["totalItems"]).to eq("1")
        expect(result.dig("list_item", 0, "displayName")).to eq("All")
      end

      context "when term not matching case sensitively" do
        context "when vocabulary", vcr: "searcher_ci_vocab" do
          let(:value) { "alL" }

          it "returns expected hash" do
            expect(result.key?("warnings")).to be true
            warning = result["warnings"].first
            expect(warning[:category]).to eq("case_insensitive_match")
            expect(warning[:message]).to eq("Searched: #{value}. Using: All")
          end
        end

        context "when authority", vcr: "searcher_ci_authority" do
          let(:value) { "Art" }
          let(:args) do
            {value: value, type: "conceptauthorities", subtype: "concept"}
          end

          it "returns expected hash" do
            expect(result.key?("warnings")).to be true
            warning = result["warnings"].first
            expect(warning[:category]).to eq("case_insensitive_match")
            expect(warning[:message]).to eq("Searched: #{value}. Using: art")
          end
        end
      end
    end

    context "when search_if_not_cached = false" do
      let(:config) { {search_if_not_cached: false} }
      let(:value) { "All" }

      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Tools::JsonFetcher do
  subject(:fetcher) { described_class.call(url) }

  context "with bad URL" do
    let("url") { "https://bad.url.example.org" }

    it "raises UnfetchableFileError", vcr: "json_fetcher_bad_url" do
      expect { fetcher }.to raise_error(
        CollectionSpace::Mapper::UnfetchableFileError
      )
    end
  end

  context "with non-JSON URL" do
    let("url") { "https://www.collectionspace.org" }

    it "raises UnparseableJsonError", vcr: "json_fetcher_non-json_url" do
      expect { fetcher }.to raise_error(
        CollectionSpace::Mapper::UnparseableJsonError
      )
    end
  end

  context "with malformed-JSON URL" do
    # I removed the first two characters from the string returned as body
    #   in the cassette
    let("url") do
      "https://raw.githubusercontent.com/collectionspace/"\
        "cspace-config-untangler/refs/heads/main/data/mappers/"\
        "community_profiles/release_8_1_1_newstyle/core/"\
        "core_10-0-2_group.json"
    end

    it "raises UnparseableJsonError", vcr: "json_fetcher_malformed_json_url" do
      expect { fetcher }.to raise_error(
        CollectionSpace::Mapper::UnparseableJsonError
      )
    end
  end

  context "with valid JSON URL" do
    let("url") do
      "https://raw.githubusercontent.com/collectionspace/"\
        "cspace-config-untangler/refs/heads/main/data/mappers/"\
        "community_profiles/release_8_1_1_newstyle/core/"\
        "core_10-0-2_group.json"
    end

    it "returns JSON hash", vcr: "json_fetcher_valid_json_url" do
      result = fetcher
      expect(result).to be_a(Hash)
      expect(result.keys).to include(:mappings)
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Identifiers::ShortIdentifier do
  describe "#value" do
    it "generates non-hashed short identifiers for vocabularies" do
      terms = {
        "Jurgen Klopp!" => "JurgenKlopp",
        "Achillea millefolium" => "Achilleamillefolium"
      }
      result = terms.keys.map do |term|
        CollectionSpace::Mapper::Identifiers::ShortIdentifier.new(
          term: term
        ).value
      end
      expect(result).to eq(terms.values)
    end
  end
end

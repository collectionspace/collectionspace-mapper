# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Identifiers::ShortIdentifier do
  subject(:idgenerator) { described_class }

  describe ".call" do
    it "generates non-hashed short identifiers for vocabularies" do
      terms = {
        "Jurgen Klopp!" => "JurgenKlopp",
        "Achillea millefolium" => "Achilleamillefolium"
      }
      result = terms.keys.map { |term| idgenerator.call(term) }
      expect(result).to eq(terms.values)
    end
  end
end

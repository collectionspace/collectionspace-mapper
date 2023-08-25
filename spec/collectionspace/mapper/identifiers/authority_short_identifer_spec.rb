# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Identifiers::AuthorityShortIdentifier do
  subject(:idgenerator) { described_class }

  describe ".call" do
    it "generates hashed short identifiers for authorities" do
      authorities = {
        "Jurgen Klopp!" => "JurgenKlopp1289035554",
        "Achillea millefolium" => "Achilleamillefolium1482849582"
      }

      result = authorities.keys.map { |term| idgenerator.call(term) }
      expect(result).to eq(authorities.values)
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Identifiers::ShortIdentifier do
  describe "#value" do
    it "generates non-hashed short identifiers for vocabularies" do
      authorities = {
        "Jurgen Klopp!" => "JurgenKlopp",
        "Achillea millefolium" => "Achilleamillefolium"
      }

      authorities.each do |term, id|
        expect(CollectionSpace::Mapper::Identifiers::ShortIdentifier.new(
          term: term
        ).value).to eq(id)
      end
    end
  end
end

RSpec.describe CollectionSpace::Mapper::Identifiers::AuthorityShortIdentifier do
  describe "#value" do
    it "generates hashed short identifiers for authorities" do
      authorities = {
        "Jurgen Klopp!" => "JurgenKlopp1289035554",
        "Achillea millefolium" => "Achilleamillefolium1482849582"
      }

      authorities.each do |term, id|
        expect(
          CollectionSpace::Mapper::Identifiers::AuthorityShortIdentifier.new(
            term: term
          ).value
        ).to eq(id)
      end
    end
  end
end

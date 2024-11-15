# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Identifiers::AuthorityShortIdentifier do
  subject(:idgenerator) { described_class }

  describe ".call" do
    it "generates hashed short identifiers for normalized authority terms" do
      authorities = {
        "Jurgen Klopp!" => "JurgenKlopp1289035554",
        "Jurgen Klopp" => "JurgenKlopp1289035554",
        "Jurgén Klopp" => "JurgnKlopp1116712995",
        "Jurgen klopp" => "Jurgenklopp1339498236",
        "Achillea millefolium" => "Achilleamillefolium1482849582",
        "手日尸" => "spec230b137b139b230b151b165b229b176b1841974196654",
        "廿木竹" => "spec229b187b191b230b156b168b231b171b1853413799245"
      }

      result = authorities.keys.map { |term| idgenerator.call(term) }
      expect(result).to eq(authorities.values)
    end

    it "generates hashed short identifiers for exact authority terms" do
      authorities = {
        "Jurgen Klopp!" => "JurgenKlopp1344333070",
        "Jurgen Klopp" => "JurgenKlopp2369906287",
        "Jurgén Klopp" => "JurgnKlopp1760941770",
        "Jurgen klopp" => "Jurgenklopp2197261388",
        "Achillea millefolium" => "Achilleamillefolium1698421148",
        "手日尸" => "spec230b137b139b230b151b165b229b176b1842743601998",
        "廿木竹" => "spec229b187b191b230b156b168b231b171b1853049386482"
      }

      result = authorities.keys.map { |term| idgenerator.call(term, "exact") }
      expect(result).to eq(authorities.values)
    end
  end
end

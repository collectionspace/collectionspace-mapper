# frozen_string_literal: true

require "spec_helper"

RSpec.shared_examples "Mapped" do
  it "maps correctly" do
    expect(mapped_doc).to match_doc(fixture_path, handler)
  end

  # it "does not map unexpected fields" do
  #   binding.pry
  #   MatchDocMatcher.new(fixture_path, handler)

  #   expect(diff).to eq([])
  # end

  # it "maps as expected" do
  #   fixture_vals = fixture_xpaths.map{ |xpath|
  #     [xpath, standardize_value(fixture_doc.xpath(xpath).text)]
  #   }.to_h
  #   mapped_vals = fixture_xpaths.map{ |xpath|
  #     [xpath, standardize_value(mapped_doc.xpath(xpath).text)]
  #   }.to_h

  #   expect(mapped_vals).to eq(fixture_vals)
  # end
end

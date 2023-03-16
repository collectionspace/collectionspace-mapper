# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::UnknownTerm do
  describe ".from_string" do
    let(:result) { described_class.from_string(str) }

    context "with valid string (3 parts, separated by `|||`)" do
      let(:str) { "a|||b|||c" }

      it "creates new as expected" do
        expect(result).to be_a(described_class)
        expect(result.type).to eq("a")
        expect(result.subtype).to eq("b")
        expect(result.display_name).to eq("c")
        expect(result.urn).to eq(str)
      end
    end

    context "with nil" do
      let(:str) { nil }

      it "fails" do
        expect {
          result
        }.to raise_error(CollectionSpace::Mapper::UnknownTerm::ReconstituteNilError)
      end
    end
  end
end

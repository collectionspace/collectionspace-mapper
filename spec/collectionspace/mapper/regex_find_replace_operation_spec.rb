# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::RegexFindReplaceOperation do
  let(:operation) { described_class.new(opspec) }

  describe "#perform" do
    let(:opspec) { {find: "(az|oo) ", replace: '\1-', type: "regexp"} }
    let(:result) { operation.perform(value) }
    context "given blank value" do
      let(:value) { "" }
      it "returns empty string" do
        expect(result).to eq("")
      end
    end

    context "given value with no occurrences of find pattern" do
      let(:value) { "a b c d" }
      it "returns original value" do
        expect(result).to eq("a b c d")
      end
    end

    context "given value with multiple occurrences of find pattern" do
      let(:value) { "mazel book foo baz raz" }
      it "replaces them all" do
        expect(result).to eq("mazel book foo-baz-raz")
      end
    end

    context "given anchored find pattern" do
      let(:opspec) { {find: "^mazel ", replace: "Mazel ", type: "regexp"} }
      let(:value) { "mazel book foo baz raz" }
      it "replaces as expected" do
        expect(result).to eq("Mazel book foo baz raz")
      end
    end
  end
end

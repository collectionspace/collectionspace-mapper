# frozen_string_literal: true

require "spec_helper"

class FakeMapping
  attr_reader :datacolumn, :transforms
  def initialize(column, transforms)
    @datacolumn = column
    @transforms = transforms
  end
end

RSpec.describe CollectionSpace::Mapper::ValueTransformer do
  subject(:transformer) do
    described_class.new(
      value: value,
      mapping: mapping,
      handler: handler,
      response: response
    )
  end

  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper
    )
  end
  let(:profile) { "anthro" }
  let(:mapper) { "anthro_4-1-2_collectionobject" }
  let(:mapping) { FakeMapping.new(column, transforms) }
  let(:response) do
    CollectionSpace::Mapper::Response.new(
      {column => value},
      handler
    )
  end

  describe "#call", vcr: "anthro_domain_check" do
    let(:result) { transformer.call }

    context "when boolean (dentition)" do
      let(:column) { "dentition" }
      let(:transforms) {
        {special: %w[boolean]}
      }

      context "with empty string" do
        let(:value) { "" }

        it "returns false" do
          expect(result).to eq("false")
        end
      end
    end

    context "when vocabulary: behrensmeyer" do
      let(:column) { "behrensmeyerupper" }
      let(:transforms) {
        {vocabulary: "behrensmeyer", special: %w[behrensmeyer_translate]}
      }
      let(:value) { "0" }

      it "returns transformed value for retrieving refname" do
        expect(result).to eq("0 - no cracking or flaking on bone surface")
      end
    end

    context "when vocabulary: behrensmeyer" do
      let(:column) { "behrensmeyerupper" }
      let(:transforms) {
        {vocabulary: "behrensmeyer", special: %w[behrensmeyer_translate]}
      }
      let(:value) { "0" }

      it "returns transformed value for retrieving refname" do
        expect(result).to eq("0 - no cracking or flaking on bone surface")
      end
    end

    context "when agerange with replacement transformation specified" do
      let(:column) { "agerange" }
      let(:transforms) do
        {
          vocabulary: "agerange",
          special: %w[downcase_value],
          replacements: [
            {find: " - ", replace: "-", type: :plain}
          ]
        }
      end
      let(:value) { "Adolescent 26 - 75%" }

      it "returns replaced value for retrieving refname" do
        expect(result).to eq("adolescent 26-75%")
      end
    end

    context "when multiple replacements" do
      let(:column) { "title" }
      let(:value) { "rice plant" }
      let(:transforms) do
        {
          replacements: [
            {find: "[aeiou]", replace: "y", type: :regexp},
            {find: " ", replace: "%%", type: :plain},
            {find: '(\w)%%(\w)', replace: '\1 \2', type: :regexp}
          ]
        }
      end

      it "does replacements" do
        expect(result).to eq("rycy plynt")
      end
    end
  end
end

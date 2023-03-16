# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::SingleColumnRequiredField do
  subject(:field) { described_class.new("objectNumber", ["objectNumber"]) }

  describe "#present_in?" do
    let(:result){ field.present_in?(data) }

    context "when data has field key" do
      let(:data){ {"objectnumber" => "123"} }

      it "returns true" do
        expect(result).to be true
      end
    end

    context "when data lacks field key" do
      let(:data){ {"objectid" => "123"} }

      it "returns false" do
        expect(result).to be false
      end
    end
  end

  describe "#populated_in?" do
    let(:result){ field.populated_in?(data) }

    context "when field is populated" do
      let(:data){ {"objectnumber" => "123"} }

      it "returns true" do
        expect(result).to be true
      end
    end
    context "when field is not populated" do
      let(:data){ {"objectnumber" => ""} }

      it "returns false" do
        expect(result).to be false
      end
    end
  end

  describe "#missing_message" do
    let(:result){ field.missing_message }

    it "returns expected message" do
      expected = "required field missing: objectnumber must be present"
      expect(result).to eq(expected)
    end
  end
  describe "#empty_message" do
    let(:result){ field.empty_message }

    it "returns expected message" do
      expected = "required field empty: objectnumber must be populated"
      expect(result).to eq(expected)
    end
  end
end

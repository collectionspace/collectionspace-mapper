# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Dates::ChronicParser do
  subject(:parser) { described_class.new(str, handler) }

  let(:handler) do
    setup_handler(
      profile: 'anthro',
      mapper: "anthro_4-1-2_collectionobject"
    )
  end

  describe "#mappable", vcr: "anthro_domain_check" do
    let(:result) { parser.mappable }

    context "with 2022-06-23" do
      let(:str) { "2022-06-23" }

      it "returns expected" do
        esv = "2022-06-23T00:00:00.000Z"
        expect(result["dateEarliestScalarValue"]).to eq(esv)
      end
    end

    context "with 01-00-2000" do
      let(:str) { "01-00-2000" }

      it "raises error" do
        cst = CollectionSpace::Mapper::UnparseableStructuredDateError
        expect { result }.to raise_error(cst)
      end
    end
  end

  describe "#stamp", vcr: "anthro_domain_check" do
    let(:result) { parser.stamp }

    context "with 2022-06-23" do
      let(:str) { "2022-06-23" }

      it "returns expected" do
        esv = "2022-06-23T00:00:00.000Z"
        expect(result).to eq(esv)
      end
    end

    context "with 01-00-2000" do
      let(:str) { "01-00-2000" }

      it "raises error" do
        cst = CollectionSpace::Mapper::UnparseableDateError
        expect { result }.to raise_error(cst)
      end
    end
  end
end

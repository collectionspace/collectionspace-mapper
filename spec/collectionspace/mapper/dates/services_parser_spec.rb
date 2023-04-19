# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Dates::ServicesParser do
  subject(:parser){ described_class.new(str, handler) }

  let(:handler) do
    setup_handler(
      profile: "anthro",
      mapper: "anthro_4-1-2_collectionobject"
    )
  end

  describe "#mappable" do
    let(:result){ parser.mappable }

    context "with 2020-09-30", vcr: "dates_2020-09-30" do
      let(:str){ "2020-09-30" }

      it "returns expected" do
        esv = "2020-09-30T00:00:00.000Z"
        expect(result["dateEarliestScalarValue"]).to eq(esv)
      end
    end

    context "with 1-2-20" do
      let(:str){ "1-2-20" }

      it "returns expected", vcr: "dates_1-2-20" do
        esv = "0020-01-02T00:00:00.000Z"
        expect(result["dateEarliestScalarValue"]).to eq(esv)
      end
    end

    context "with 1881-", vcr: "dates_1881-" do
      let(:str){ "1881-" }

      it "raises error" do
        cst = CollectionSpace::Mapper::UnparseableStructuredDateError
        expect{ result }.to raise_error(cst)
      end
    end

    context "with 01-00-2000", vcr: "dates_01-00-2000" do
      let(:str){ "01-00-2000" }

      it "raises error" do
        cst = CollectionSpace::Mapper::UnparseableStructuredDateError
        expect{ result }.to raise_error(cst)
      end
    end
  end

  describe "#stamp" do
    let(:result){ parser.stamp }

    context "with 2020-09-30", vcr: "dates_2020-09-30" do
      let(:str){ "2020-09-30" }

      it "returns expected" do
        esv = "2020-09-30T00:00:00.000Z"
        expect(result).to eq(esv)
      end
    end

    context "with 1-2-20", vcr: "dates_1-2-20" do
      let(:str){ "1-2-20" }

      it "returns expected" do
        esv = "0020-01-02T00:00:00.000Z"
        expect(result).to eq(esv)
      end
    end

    context "with 1881-", vcr: "dates_1881-" do
      let(:str){ "1881-" }

      it "raises error" do
        cst = CollectionSpace::Mapper::UnparseableDateError
        expect{ result }.to raise_error(cst)
      end
    end

    context "with 01-00-2000", vcr: "dates_01-00-2000" do
      let(:str){ "01-00-2000" }

      it "raises error" do
        cst = CollectionSpace::Mapper::UnparseableDateError
        expect{ result }.to raise_error(cst)
      end
    end
  end
end

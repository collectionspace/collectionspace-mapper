# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Dates::YearDateCreator do
  subject(:creator) { described_class.new(str) }

  before do
    setup_handler(
      profile: 'anthro',
      mapper_path: "spec/fixtures/files/mappers/release_6_1/anthro/"\
        "anthro_4-1-2_collectionobject.json"
    )
  end
  after{ CollectionSpace::Mapper.reset_config }

  describe "#mappable" do
    let(:result) { creator.mappable }

    context "with 2022" do
      let(:str) { "2022" }

      it "returns expected" do
        expected = {
          "dateDisplayDate" => "2022",
          "dateEarliestSingleYear" => "2022",
          "dateEarliestSingleMonth" => "1",
          "dateEarliestSingleDay" => "1",
          "dateEarliestScalarValue" => "2022-01-01T00:00:00.000Z",
          "dateLatestYear" => "2022",
          "dateLatestMonth" => "12",
          "dateLatestDay" => "31",
          "dateLatestScalarValue" => "2023-01-01T00:00:00.000Z",
          "scalarValuesComputed" => "true",
          "dateEarliestSingleEra" => "urn:cspace:c.anthro.collectionspace.org"\
            ":vocabularies:name(dateera):item:name(ce)'CE'",
          "dateLatestEra" => "urn:cspace:c.anthro.collectionspace.org"\
            ":vocabularies:name(dateera):item:name(ce)'CE'"
        }
        expect(result).to eq(expected)
      end
    end

    context "with 1" do
      let(:str) { "1" }

      it "returns expected" do
        expected = {
          "dateDisplayDate" => "1",
          "dateEarliestSingleYear" => "1",
          "dateEarliestSingleMonth" => "1",
          "dateEarliestSingleDay" => "1",
          "dateEarliestScalarValue" => "0001-01-01T00:00:00.000Z",
          "dateLatestYear" => "1",
          "dateLatestMonth" => "12",
          "dateLatestDay" => "31",
          "dateLatestScalarValue" => "0002-01-01T00:00:00.000Z",
          "scalarValuesComputed" => "true",
          "dateEarliestSingleEra" => "urn:cspace:c.anthro.collectionspace.org"\
            ":vocabularies:name(dateera):item:name(ce)'CE'",
          "dateLatestEra" => "urn:cspace:c.anthro.collectionspace.org"\
            ":vocabularies:name(dateera):item:name(ce)'CE'"
        }
        expect(result).to eq(expected)
      end
    end

    context "with foo" do
      let(:str) { "foo" }

      it "raises error" do
        cst = CollectionSpace::Mapper::UnparseableStructuredDateError
        expect { result }.to raise_error(cst)
      end
    end
  end

  describe "#stamp" do
    let(:result) { creator.stamp }

    context "with 2022" do
      let(:str) { "2022" }

      it "returns expected" do
        expected = "2022-01-01T00:00:00.000Z"
        expect(result).to eq(expected)
      end
    end

    context "with foo" do
      let(:str) { "foo" }

      it "raises error" do
        cst = CollectionSpace::Mapper::UnparseableDateError
        expect { result }.to raise_error(cst)
      end
    end
  end
end

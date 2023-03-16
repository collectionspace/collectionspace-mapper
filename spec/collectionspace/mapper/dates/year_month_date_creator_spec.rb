# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Dates::YearMonthDateCreator do
  subject(:creator) { described_class.new(str, handler) }
  let(:client) { anthro_client }
  let(:cache) { anthro_cache }
  let(:csid_cache) { anthro_csid_cache }
  let(:config) { CollectionSpace::Mapper::Config.new }
  let(:searcher) do
    CollectionSpace::Mapper::Searcher.new(client: client, config: config)
  end
  let(:handler) do
    CollectionSpace::Mapper::Dates::StructuredDateHandler.new(
      client: client,
      cache: cache,
      csid_cache: csid_cache,
      config: config,
      searcher: searcher
    )
  end

  describe "#mappable" do
    let(:result) { creator.mappable }

    context "with 2022-06" do
      let(:str) { "2022-06" }

      it "returns expected" do
        expected = {
          "dateDisplayDate" => "2022-06",
          "dateEarliestSingleYear" => "2022",
          "dateEarliestSingleMonth" => "6",
          "dateEarliestSingleDay" => "1",
          "dateEarliestSingleEra" => "urn:cspace:c.anthro.collectionspace.org"\
            ":vocabularies:name(dateera):item:name(ce)'CE'",
          "dateLatestYear" => "2022",
          "dateLatestMonth" => "6",
          "dateLatestDay" => "30",
          "dateLatestEra" => "urn:cspace:c.anthro.collectionspace.org"\
            ":vocabularies:name(dateera):item:name(ce)'CE'",
          "dateEarliestScalarValue" => "2022-06-01T00:00:00.000Z",
          "dateLatestScalarValue" => "2022-07-01T00:00:00.000Z",
          "scalarValuesComputed" => "true"
        }

        expect(result).to eq(expected)
      end
    end

    context "with 1865-75" do
      let(:str) { "1865-75" }

      it "raises error" do
        cst = CollectionSpace::Mapper::Dates::UnparseableStructuredDateError
        expect { result }.to raise_error(cst)
      end
    end
  end

  describe "#stamp" do
    let(:result) { creator.stamp }

    context "with 2022-06" do
      let(:str) { "2022-06" }

      it "returns expected" do
        expected = "2022-06-01T00:00:00.000Z"
        expect(result).to eq(expected)
      end
    end

    context "with 1865-75" do
      let(:str) { "1865-75" }

      it "raises error" do
        cst = CollectionSpace::Mapper::Dates::UnparseableDateError
        expect { result }.to raise_error(cst)
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Dates::CspaceDate do
  subject(:csdate) { described_class.new(date_string, handler) }

  let(:handler) do
    setup_handler(
      profile: "anthro",
      mapper: "anthro_4-1-2_collectionobject",
      config: config
    )
  end
  let(:config) { {} }

  context "with one digit month", vcr: "dates_2019-5-20" do
    let(:date_string) { "2019-5-20" }

    it "parses as expected" do
      expect(csdate.mappable["dateEarliestScalarValue"]).to start_with(
        "2019-05-20"
      )
      expect(csdate.mappable["dateDisplayDate"]).to eq(date_string)
    end
  end

  context "when date string is Chronic parseable (e.g. 2020-09-30)",
    vcr: "dates_2020-09-30" do
      let(:date_string) { "2020-09-30" }

      it "parses as expected" do
        expect(csdate.mappable["dateDisplayDate"]).to eq("2020-09-30")
        expect(csdate.mappable["dateEarliestSingleYear"]).to eq("2020")
        expect(csdate.mappable["dateEarliestSingleMonth"]).to eq("9")
        expect(csdate.mappable["dateEarliestSingleDay"]).to eq("30")
        urn = "urn:cspace:c.anthro.collectionspace.org:vocabularies:"\
          "name(dateera):item:name(ce)'CE'"
        expect(csdate.mappable["dateEarliestSingleEra"]).to eq(urn)
        esv = "2020-09-30T00:00:00.000Z"
        expect(csdate.mappable["dateEarliestScalarValue"]).to eq(esv)
        lsv = "2020-10-01T00:00:00.000Z"
        expect(csdate.mappable["dateLatestScalarValue"]).to eq(lsv)
      end

      context "when date format is ambiguous re: month/date (e.g. 1/2/2020)",
        vcr: "dates_1s2s2020" do
          let(:date_string) { "1/2/2020" }
          let(:result) { csdate.mappable["dateEarliestScalarValue"] }

          context "when no date_format specified in config" do
            it "defaults to M/D/Y interpretation" do
              expect(result).to start_with("2020-01-02")
            end
          end

          context "when date_format in config = day month year" do
            let(:config) { {date_format: "day month year"} }

            it "interprets as D/M/Y" do
              expect(result).to start_with("2020-02-01")
            end
          end
        end
    end

  context "when date string has two-digit year (e.g. 9/19/91)",
    vcr: "dates_9s19s91" do
      let(:date_string) { "9/19/91" }
      let(:result) { csdate.mappable["dateEarliestSingleYear"] }

      it "Chronic parses date with coerced 4-digit year" do
        expect(result).to eq("1991")
      end

      context "when config[:two_digit_year_handling] = literal" do
        let(:config) { {two_digit_year_handling: "literal"} }

        it "Services parses date with uncoerced 2-digit year" do
          expect(result).to eq("91")
        end
      end
    end

  context "when date string is not Chronic parseable (e.g. 1/2/2000 - "\
    "12/21/2001)", vcr: "dates_1s2s2000_-_12s21s2001" do
      let(:date_string) { "1/2/2000 - 12/21/2001" }

      it "processed as expected" do
        expect(csdate.mappable).to be_a(Hash)
        expect(csdate.mappable["dateEarliestSingleMonth"]).to eq("1")
        expect(csdate.stamp).to start_with("2000-01-02")
      end
    end

  context "when date string is not Chronic or services parseable",
    vcr: "dates_VIII.XIV.MMXX" do
      context "date = VIII.XIV.MMXX" do
        let(:date_string) { "VIII.XIV.MMXX" }

        it "raises error" do
          cst = CollectionSpace::Mapper::UnparseableStructuredDateError
          expect { csdate.mappable }.to raise_error(cst)
        end
      end
    end

  context "when date string is Chronic parseable but we want services parsing",
    vcr: "dates_march_2020" do
      context "when date string = march 2020" do
        let(:date_string) { "march 2020" }
        let(:res) { csdate.mappable }

        it "parses as expected" do
          expect(res["dateEarliestScalarValue"]).to eq(
            "2020-03-01T00:00:00.000Z"
          )
          expect(res["dateLatestScalarValue"]).to eq("2020-04-01T00:00:00.000Z")
          expect(res["dateEarliestSingleMonth"]).to eq("3")
          expect(res["dateLatestMonth"]).to eq("3")
          expect(res["dateEarliestSingleDay"]).to eq("1")
          expect(res["dateLatestDay"]).to eq("31")
          expect(res["dateEarliestSingleYear"]).to eq("2020")
          expect(res["dateLatestYear"]).to eq("2020")
        end
      end

      context "when date string = 2020-03" do
        let(:date_string) { "2020-03" }
        let(:res) { csdate.mappable }

        it "parses as expected" do
          expect(res["dateEarliestScalarValue"]).to eq(
            "2020-03-01T00:00:00.000Z"
          )
          expect(res["dateLatestScalarValue"]).to eq("2020-04-01T00:00:00.000Z")
          expect(res["dateEarliestSingleMonth"]).to eq("3")
          expect(res["dateLatestMonth"]).to eq("3")
          expect(res["dateEarliestSingleDay"]).to eq("1")
          expect(res["dateLatestDay"]).to eq("31")
          expect(res["dateEarliestSingleYear"]).to eq("2020")
          expect(res["dateLatestYear"]).to eq("2020")
        end
      end

      context "when date string = 2002" do
        let(:date_string) { "2002" }
        let(:res) { csdate.mappable }

        it "parses as expected" do
          expect(res["dateEarliestScalarValue"]).to eq(
            "2002-01-01T00:00:00.000Z"
          )
          expect(res["dateLatestScalarValue"]).to eq("2003-01-01T00:00:00.000Z")
          expect(res["dateEarliestSingleMonth"]).to eq("1")
          expect(res["dateLatestMonth"]).to eq("12")
          expect(res["dateEarliestSingleDay"]).to eq("1")
          expect(res["dateLatestDay"]).to eq("31")
          expect(res["dateEarliestSingleYear"]).to eq("2002")
          expect(res["dateLatestYear"]).to eq("2002")
        end
      end
    end
end

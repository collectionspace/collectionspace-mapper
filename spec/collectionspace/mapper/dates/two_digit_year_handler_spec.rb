# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Dates::TwoDigitYearHandler,
  vcr: "anthro_domain_check" do
    subject(:creator){ described_class.new(str, handler) }

    let(:handler) do
      setup_handler(
        profile: "anthro",
        mapper: "anthro_4-1-2_collectionobject",
        config: config
      )
    end

    let(:str){ "1-2-20" }

    describe "#mappable" do
      let(:result){ creator.mappable }

      context "with literal", vcr: "dates_1-2-20" do
        let(:config){ {two_digit_year_handling: "literal"} }

        it "returns expected" do
          expected = "0020-01-02T00:00:00.000Z"
          expect(result["dateEarliestScalarValue"]).to eq(expected)
        end

        context "with unparseble date" do
          let(:str){ "not a date" }

          it "raises error" do
            expect{ result }.to raise_error(
              CollectionSpace::Mapper::UnparseableStructuredDateError
            )
          end
        end
      end

      context "with coerce" do
        let(:config){ {two_digit_year_handling: "coerce"} }

        it "returns expected" do
          expected = "2020-01-02T00:00:00.000Z"
          expect(result["dateEarliestScalarValue"]).to eq(expected)
        end

        context "with unparseble date" do
          let(:str){ "not a date" }

          it "raises error" do
            expect{ result }.to raise_error(
              CollectionSpace::Mapper::UnparseableStructuredDateError
            )
          end
        end
      end
    end

    describe "#stamp" do
      let(:result){ creator.stamp }

      context "with literal", vcr: "dates_1-2-20" do
        let(:config){ {two_digit_year_handling: "literal"} }

        it "returns expected" do
          expected = "0020-01-02T00:00:00.000Z"
          expect(result).to eq(expected)
        end
      end

      context "with coerce" do
        let(:config){ {two_digit_year_handling: "coerce"} }

        it "returns expected" do
          expected = "2020-01-02T00:00:00.000Z"
          expect(result).to eq(expected)
        end
      end
    end
  end

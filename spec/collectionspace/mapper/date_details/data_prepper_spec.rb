# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DateDetails::DataPrepper do
  subject(:prepper){ described_class.new(datahash, handler) }

  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper,
      config: config
    )
  end
  let(:profile){ "core" }
  let(:mapper){ "core_6-1-0_collectionobject" }
  let(:baseconfig){ {"delimiter" => "|", "batch_mode" => "date details"} }
  let(:customcfg){ {} }
  let(:config){ baseconfig.merge(customcfg) }

  describe "#prep", vcr: "core_domain_check" do
    let(:response){ prepper.prep }

    describe "leading/trailing space stripping" do
      context "when identifier field" do
        let(:datahash) do
          {
            "objectNumber" => "123 ",
            "date_field_group" => "objectProductionDateGroup",
            "scalarValuesComputed" => "f"
          }
        end
        let(:result){ response.transformed_data["objectnumber"] }

        it "strips leading/trailing spaces from id field(s)" do
          expect(result).to eq(["123"])
        end

        context "with strip_id_values = false" do
          let(:customcfg){ {strip_id_values: false} }

          it "does not strip leading/trailing spaces from id field(s)" do
            expect(result).to eq(["123 "])
          end
        end
      end
    end

    describe "term prep" do
      let(:result){ response.transformed_data }
      let(:datahash) do
        get_datahash(
          path: "spec/support/datahashes/date_details/"\
            "object_production_date_2.json"
        )
      end

      it "adds expected UsedTerm objects to response.terms" do
        chk = response.terms
          .map{ |term| [term.field, term.urn] }
          .to_h
        expected = {
          "datelatestcertainty" => "urn:cspace:c.core.collectionspace.org:"\
            "vocabularies:name(datecertainty):item:name(circa)'Circa'",
          "datelatestera" => "urn:cspace:c.core.collectionspace.org:"\
            "vocabularies:name(dateera):item:name(ce)'CE'",
          "dateearliestsinglecertainty" =>
            "urn:cspace:c.core.collectionspace.org:"\
            "vocabularies:name(datecertainty):item:name(circa)'Circa'",
          "dateearliestsingleera" =>
            "urn:cspace:c.core.collectionspace.org:"\
            "vocabularies:name(dateera):item:name(ce)'CE'"
        }
        expect(chk).to eq(expected)
      end
    end

    describe "#transform_date_fields" do
      let(:result){ response.transformed_data }
      let(:expectedkeys) do
        ["objectnumber", targetfield].sort
      end
      let(:targetfield){ "objectproductiondategroup" }
      let(:fieldresult){ result[targetfield] }
      let(:chk){ fieldresult.map{ |e| e.class }.uniq }

      context "when single value date details" do
        let(:datahash) do
          get_datahash(
            path: "spec/support/datahashes/date_details/"\
              "object_production_date_2.json"
          )
        end

        it "results in mappable structured date hashes" do
          expect(fieldresult.length).to eq(1)
          expect(chk).to eq([Hash])
          expect(response.warnings).to be_empty
        end
      end

      context "when multi value date details" do
        let(:datahash) do
          get_datahash(
            path: "spec/support/datahashes/date_details/"\
              "object_production_date_3.json"
          )
        end

        it "results in mappable structured date hashes" do
          expect(fieldresult.length).to eq(2)
          expect(chk).to eq([Hash])
          expect(response.warnings).to be_empty
        end
      end

      context "when uneven multi value date details" do
        let(:datahash) do
          get_datahash(
            path: "spec/support/datahashes/date_details/"\
              "object_production_date_3_uneven.json"
          )
        end

        it "results in mappable structured date hashes" do
          expect(fieldresult.length).to eq(3)
          expect(chk).to eq([Hash])
          expect(response.warnings.length).to eq(1)
          expect(response.warnings.first).to match(
            /^Uneven field group values in date details/
          )
        end
      end
    end
  end
end

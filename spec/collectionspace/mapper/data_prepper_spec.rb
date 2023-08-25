# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataPrepper do
  subject(:prepper) { described_class.new(datahash, handler) }

  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper,
      config: config
    )
  end
  let(:profile) { "anthro" }
  let(:mapper) { "anthro_4-1-2_collectionobject" }
  let(:baseconfig) { {delimiter: ";"} }
  let(:customcfg) { {} }
  let(:config) { baseconfig.merge(customcfg) }

  describe "#prep", vcr: "anthro_domain_check" do
    let(:response) { prepper.prep }

    describe "leading/trailing space stripping" do
      context "when identifier field" do
        let(:datahash) { {"objectNumber" => "123 "} }
        let(:result) { response.transformed_data["objectnumber"] }

        it "strips leading/trailing spaces from id field(s)" do
          expect(result).to eq(["123"])
        end

        context "with strip_id_values = false" do
          let(:customcfg) { {strip_id_values: false} }

          it "does not strip leading/trailing spaces from id field(s)" do
            expect(result).to eq(["123 "])
          end
        end
      end

      context "when other data field" do
        let(:datahash) do
          {
            "objectNumber" => "123 ",
            "numberValue" => " 456 ;786 ;288"
          }
        end
        let(:result) { response.transformed_data["numbervalue"] }

        it "strips leading/trailing spaces from id field(s)" do
          expect(result).to eq(["456", "786", "288"])
        end
      end
    end

    describe "term prep" do
      let(:result) { response.transformed_data }
      let(:datahash) do
        {
          "objectnumber" => "123",
          "title" => 'A "Man";A Woman',
          "titleLanguage" => "English;English",
          "titleTranslation" => "Un Homme^^Hombre; Une Femme^^Fraulein",
          "titleTranslationLanguage" => "French^^Spanish;French^^German",
          "titleType" => "collection;generic",
          "behrensmeyerUpper" => "2; 5",
          "dentition" => ";y"
        }
      end

      it "returns expected result for mappings" do
        title_expected = [
          [
            "urn:cspace:c.anthro.collectionspace.org:vocabularies:name("\
              "languages):item:name(fra)'French'",
            "urn:cspace:c.anthro.collectionspace.org:vocabularies:name("\
              "languages):item:name(spa)'Spanish'"
          ],
          [
            "urn:cspace:c.anthro.collectionspace.org:vocabularies:name("\
              "languages):item:name(fra)'French'",
            "urn:cspace:c.anthro.collectionspace.org:vocabularies:name("\
              "languages):item:name(deu)'German'"
          ]
        ]
        behrensmeyer_expected = [
          "urn:cspace:c.anthro.collectionspace.org:vocabularies:name"\
            "(behrensmeyer):item:name(2)'2 - longitudinal cracks, exfoliation "\
            "on surface'",
          "urn:cspace:c.anthro.collectionspace.org:vocabularies:name"\
            "(behrensmeyer):item:name(5)'5 - bone crumbling in situ, large "\
            "splinters'"
        ]
        expect(result["titletranslationlanguage"]).to eq(title_expected)
        expect(result["behrensmeyerupper"]).to eq(behrensmeyer_expected)
        expect(result["dentition"]).to eq(["false", "true"])
      end

      it "adds expected UsedTerm objects to response.terms" do
        chk = response.terms.select { |t|
          t.field == "titletranslationlanguage"
        }
        expect(chk.length).to eq(4)
      end
    end

    describe "#transform_date_fields" do
      let(:result) { response.transformed_data }

      context "when field is a structured date" do
        let(:datahash) do
          {
            "objectnumber" => "123",
            "identdategroup" => "2019-09-30;4/5/2020"
          }
        end

        it "results in mappable structured date hashes" do
          chk = result["identdategroup"].map { |e| e.class }.uniq
          expect(chk).to eq([Hash])
        end
      end

      context "when field is an unstructured date" do
        let(:datahash) do
          {
            "objectnumber" => "123",
            "annotationdate" => "2019-09-30;4/5/2020"
          }
        end

        it "results in array of datestamp strings" do
          chk = result["annotationdate"].select { |e| e["T00:00:00.000Z"] }
          expect(chk.size).to eq(2)
        end
      end

      context "when field is an unparseable unstructured date" do
        let(:datahash) do
          {
            "objectnumber" => "123",
            "annotationdate" => "1881-"
          }
        end

        it "adds error to response" do
          errors = response.errors
          expect(errors.length).to eq(1)
          err = errors.first
          ex_err = {
            category: :unparseable_date,
            field: "annotationdate",
            value: "1881-",
            message: "Unparseable date value in annotationdate: `1881-`"
          }
          expect(err).to eq(ex_err)
        end
      end

      context "when field is an unparseable structured date" do
        let(:datahash) do
          {
            "objectnumber" => "123",
            "objectproductiondategroup" => "1881-"
          }
        end

        it "adds warning to response" do
          warnings = response.warnings
          expect(warnings.length).to eq(1)
          wrn = warnings.first
          expect(wrn[:category]).to eq(:unparseable_structured_date)
        end
      end
    end

    describe "#combine_data_values" do
      let(:result) { response.combined_data[xpath][field] }
      let(:datahash) do
        {
          "objectnumber" => "123",
          "fieldCollectorPerson" => "Ann Analyst;Gabriel Solares",
          "fieldCollectorOrganization" => "Organization 1",
          "objectProductionPeopleArchculture" => "Blackfoot",
          "objectProductionPeopleEthculture" => "Batak"
        }
      end

      context "when multi-authority field is not in repeating group" do
        let(:xpath) { "collectionobjects_common/fieldCollectors" }
        let(:field) { "fieldCollector" }

        it "combines values properly" do
          expected = [
            "urn:cspace:c.anthro.collectionspace.org:personauthorities:name("\
              "person):item:name(AnnAnalyst1594848799340)'Ann Analyst'",
            "urn:cspace:c.anthro.collectionspace.org:personauthorities:name("\
              "person):item:name(GabrielSolares1594848906847)'Gabriel Solares'",
            "urn:cspace:c.anthro.collectionspace.org:orgauthorities:name("\
              "organization):item:name(Organization11587136583004)"\
              "'Organization 1'"
          ]
          expect(result).to eq(expected)
        end
      end

      context "when multi-authority field is in repeating group" do
        let(:xpath) do
          "collectionobjects_common/objectProductionPeopleGroupList/"\
            "objectProductionPeopleGroup"
        end
        let(:field) { "objectProductionPeople" }

        it "combines values properly" do
          expected = [
            "urn:cspace:c.anthro.collectionspace.org:conceptauthorities:name("\
              "archculture):item:name(Blackfoot1576172504869)'Blackfoot'",
            "urn:cspace:c.anthro.collectionspace.org:conceptauthorities:name("\
              "ethculture):item:name(Batak1576172496916)'Batak'"
          ]
          expect(result).to eq(expected)
        end

        context "and one or more combined field values is blank",
          vcr: "core_domain_check" do
            let(:profile) { "core" }
            let(:mapper) { "core_6-1-0_conservation" }
            let(:datahash) do
              {
                "conservationNumber" => "CT2020.7",
                "status" =>
                  "Analysis complete;Treatment approved;;Treatment in progress",
                "statusDate" => ""
              }
            end
            let(:xpath) {
              "conservation_common/conservationStatusGroupList/"\
                "conservationStatusGroup"
            }

            it "removes empty fields from combined data response" do
              result = response.combined_data[xpath].keys
              expect(result).to_not include("statusDate")
            end

            it "removes empty fields from fieldmapping list" do
              result = response.xpaths[xpath].mappings
              expect(result.length).to eq(1)
            end
          end
      end

      context "when multi-authority field is part of repeating subgroup",
        vcr: "core_domain_check" do
        let(:profile) { "core" }
        let(:mapper) { "core_6-1-0_media" }
        let(:xpath) {
          "media_common/measuredPartGroupList/measuredPartGroup/"\
            "dimensionSubGroupList/dimensionSubGroup"
        }
        let(:field) { "measuredBy" }

        context "when there is more than one group" do
          let(:datahash) do
            {
              "identificationNumber" => "MR2020.1.77",
              "measuredPart" => "framed;",
              "dimensionSummary" => "Past is gone;Summary",
              "dimension" => "base^^^^weight^^circumference;height^^width",
              "measuredByPerson" => "Gomongo^^Comodore;Gomongo",
              "measuredByOrganization" => "Cuckoo^^;Cuckoo",
              "measurementMethod" =>
                "sliding_calipers^^theodolite_total_station^^electronic_"\
                "distance_measurement^^measuring_tape_cloth;measuring_tape_"\
                "cloth^^measuring_tape_cloth",
              "value" => "25^^83^^56^^10;5^^5",
              "measurementUnit" =>
                "centimeters^^carats^^kilograms^^inches;inches^^inches",
              "valueQualifier" => "cm^^ct^^kg^^in;q1^^q2",
              "valueDate" =>
                "2020-09-23^^2020-09-28^^2020-09-25^^2020-09-30;2020-07-21^^"\
                "2020-07-21"
            }
          end

          it "combines values properly" do
            expected = [
              [
                "urn:cspace:c.core.collectionspace.org:personauthorities:name"\
                  "(person):item:name(Gomongo1599463746195)'Gomongo'",
                "urn:cspace:c.core.collectionspace.org:personauthorities:name"\
                  "(person):item:name(Comodore1599463826401)'Comodore'",
                "urn:cspace:c.core.collectionspace.org:orgauthorities:name"\
                  "(organization):item:name(Cuckoo1599463786824)'Cuckoo'",
                ""
              ],
              [
                "urn:cspace:c.core.collectionspace.org:personauthorities:name"\
                  "(person):item:name(Gomongo1599463746195)'Gomongo'",
                "urn:cspace:c.core.collectionspace.org:orgauthorities:name"\
                  "(organization):item:name(Cuckoo1599463786824)'Cuckoo'"
              ]
            ]
            expect(result).to eq(expected)
          end
        end

        context "when there is only one group" do
          let(:datahash) do
            {
              "identificationNumber" => "MR2020.1.77",
              "measuredPart" => "framed",
              "dimensionSummary" => "Past is gone",
              "dimension" => "base^^^^weight^^circumference",
              "measuredByPerson" => "Gomongo^^Comodore",
              "measuredByOrganization" => "Cuckoo^^",
              "measurementMethod" =>
                "sliding_calipers^^theodolite_total_station^^electronic_"\
                "distance_measurement^^measuring_tape_cloth",
              "value" => "25^^83^^56^^10",
              "measurementUnit" => "centimeters^^carats^^kilograms^^inches",
              "valueQualifier" => "cm^^ct^^kg^^in",
              "valueDate" => "2020-09-23^^2020-09-28^^2020-09-25^^2020-09-30"
            }
          end

          it "combines values properly" do
            expected = [
              [
                "urn:cspace:c.core.collectionspace.org:personauthorities:name"\
                  "(person):item:name(Gomongo1599463746195)'Gomongo'",
                "urn:cspace:c.core.collectionspace.org:personauthorities:name"\
                  "(person):item:name(Comodore1599463826401)'Comodore'",
                "urn:cspace:c.core.collectionspace.org:orgauthorities:name"\
                  "(organization):item:name(Cuckoo1599463786824)'Cuckoo'",
                ""
              ]
            ]
            expect(result).to eq(expected)
          end
        end
      end
    end
  end
end

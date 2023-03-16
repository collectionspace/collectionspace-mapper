# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataPrepper do
  let(:delimiter) { ";" }
  let(:client) { anthro_client }
  let(:cache) { anthro_cache }
  let(:csid_cache) { anthro_csid_cache }
  let(:mapperpath) {
    "spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_collectionobject.json"
  }
  let(:mapper) { get_json_record_mapper(mapperpath) }
  let(:config) do
    {
      delimiter: delimiter
    }
  end
  let(:handler) do
    CollectionSpace::Mapper::DataHandler.new(record_mapper: mapper,
      client: client,
      cache: cache,
      csid_cache: csid_cache,
      config: config)
  end
  let(:prepper) {
    CollectionSpace::Mapper::DataPrepper.new(datahash, handler.searcher,
      handler)
  }
  let(:datahash) { {"objectNumber" => "123"} }

  describe "#process_xpaths" do
    context "when authority record" do
      let(:client) { core_client }
      let(:cache) { core_cache }
      let(:mapperpath) {
        "spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_place-local.json"
      }
      let(:datahash) { {"termdisplayname" => "Silk Hope"} }

      it "keeps mapping for shortIdentifier in xphash" do
        result = prepper.prep.xphash["places_common"][:mappings].select do |mapping|
          mapping.fieldname == "shortIdentifier"
        end
        expect(result.length).to eq(1)
      end
    end
  end

  describe "#handle_term_fields" do
    let(:datahash) do
      {
        "objectnumber" => "123",
        "title" => 'A "Man";A Woman',
        "titleLanguage" => "English;English",
        "titleTranslation" => "Un Homme^^Hombre; Une Femme^^Fraulein",
        "titleTranslationLanguage" => "French^^Spanish;French^^German",
        "titleType" => "collection;generic"
      }
    end
    it "returns expected result for mapping" do
      res = prepper.prep.response.transformed_data["titletranslationlanguage"]
      expected = [["urn:cspace:c.anthro.collectionspace.org:vocabularies:name(languages):item:name(fra)'French'",
        "urn:cspace:c.anthro.collectionspace.org:vocabularies:name(languages):item:name(spa)'Spanish'"],
        ["urn:cspace:c.anthro.collectionspace.org:vocabularies:name(languages):item:name(fra)'French'",
          "urn:cspace:c.anthro.collectionspace.org:vocabularies:name(languages):item:name(deu)'German'"]]
      expect(res).to eq(expected)
    end

    it "adds expected term Hashes to response.terms" do
      chk = prepper.prep.response.terms.select { |t|
        t[:field] == "titletranslationlanguage"
      }
      expect(chk.length).to eq(4)
    end
  end

  describe "#transform_date_fields" do
    let(:datahash) do
      {
        "objectnumber" => "123",
        "annotationdate" => "12/19/2019;12/10/2019",
        "identdategroup" => "2019-09-30;4/5/2020"
      }
    end
    context "when field is a structured date" do
      it "results in mappable structured date hashes" do
        res = prepper.prep.response.transformed_data["identdategroup"]
        chk = res.map { |e| e.class }.uniq
        expect(chk).to eq([Hash])
      end
    end
    context "when field is an unstructured date" do
      it "results in array of datestamp strings" do
        res = prepper.prep.response.transformed_data["annotationdate"]
        chk = res.select { |e| e["T00:00:00.000Z"] }
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
        errors = prepper.prep.response.errors
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
        warnings = prepper.prep.response.warnings
        expect(warnings.length).to eq(1)
        wrn = warnings.first
        expect(wrn[:category]).to eq(:unparseable_structured_date)
      end
    end
  end

  describe "#combine_data_values" do
    let(:datahash) do
      {
        "objectnumber" => "123",
        "fieldCollectorPerson" => "Ann Analyst;Gabriel Solares",
        "fieldCollectorOrganization" => "Organization 1",
        "objectProductionPeopleArchculture" => "Blackfoot",
        "objectProductionPeopleEthculture" => "Batak"
      }
    end
    context "when multi-authority field is not part of repeating field group" do
      it "combines values properly" do
        xpath = "collectionobjects_common/fieldCollectors"
        result = prepper.prep.response.combined_data[xpath]["fieldCollector"]
        expected = [
          "urn:cspace:c.anthro.collectionspace.org:personauthorities:name(person):item:name(AnnAnalyst1594848799340)'Ann Analyst'",
          "urn:cspace:c.anthro.collectionspace.org:personauthorities:name(person):item:name(GabrielSolares1594848906847)'Gabriel Solares'",
          "urn:cspace:c.anthro.collectionspace.org:orgauthorities:name(organization):item:name(Organization11587136583004)'Organization 1'"
        ]
        expect(result).to eq(expected)
      end
    end

    context "when multi-authority field is part of repeating field group" do
      it "combines values properly" do
        xpath = "collectionobjects_common/objectProductionPeopleGroupList/objectProductionPeopleGroup"
        result = prepper.prep.response.combined_data[xpath]["objectProductionPeople"]
        expected = [
          "urn:cspace:c.anthro.collectionspace.org:conceptauthorities:name(archculture):item:name(Blackfoot1576172504869)'Blackfoot'",
          "urn:cspace:c.anthro.collectionspace.org:conceptauthorities:name(ethculture):item:name(Batak1576172496916)'Batak'"
        ]
        expect(result).to eq(expected)
      end

      context "and one or more combined field values is blank" do
        let(:client) { core_client }
        let(:cache) { core_cache }
        let(:mapperpath) {
          "spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_conservation.json"
        }
        let(:datahash) do
          {
            "conservationNumber" => "CT2020.7",
            "status" => "Analysis complete;Treatment approved;;Treatment in progress",
            "statusDate" => ""
          }
        end
        let(:xpath) {
          "conservation_common/conservationStatusGroupList/conservationStatusGroup"
        }

        it "removes empty fields from combined data response" do
          result = prepper.prep.response.combined_data[xpath].keys
          expect(result).to_not include("statusDate")
        end

        it "removes empty fields from fieldmapping list passed on for mapping" do
          result = prepper.prep.xphash[xpath][:mappings]
          expect(result.length).to eq(1)
        end
      end
    end

    context "when multi-authority field is part of repeating field subgroup" do
      let(:client) { core_client }
      let(:cache) { core_cache }
      let(:mapperpath) {
        "spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_media.json"
      }
      let(:xpath) {
        "media_common/measuredPartGroupList/measuredPartGroup/dimensionSubGroupList/dimensionSubGroup"
      }

      context "when there is more than one group" do
        let(:datahash) do
          {
            "identificationNumber" => "MR2020.1.77",
            "measuredPart" => "framed;",
            "dimensionSummary" => "Past is gone;Summary",
            "dimension" => "base^^^^weight^^circumference;height^^width",
            "measuredByPerson" => "Gomongo^^Comodore;Gomongo",
            "measuredByOrganization" => "Cuckoo^^;Cuckoo",
            "measurementMethod" => "sliding_calipers^^theodolite_total_station^^electronic_distance_measurement^^measuring_tape_cloth;measuring_tape_cloth^^measuring_tape_cloth",
            "value" => "25^^83^^56^^10;5^^5",
            "measurementUnit" => "centimeters^^carats^^kilograms^^inches;inches^^inches",
            "valueQualifier" => "cm^^ct^^kg^^in;q1^^q2",
            "valueDate" => "2020-09-23^^2020-09-28^^2020-09-25^^2020-09-30;2020-07-21^^^2020-07-21"
          }
        end

        # TODO: why does this call services api?
        it "combines values properly", services_call: true do
          result = prepper.prep.response.combined_data[xpath]["measuredBy"]
          expected = [
            [
              "urn:cspace:c.core.collectionspace.org:personauthorities:name(person):item:name(Gomongo1599463746195)'Gomongo'",
              "urn:cspace:c.core.collectionspace.org:personauthorities:name(person):item:name(Comodore1599463826401)'Comodore'",
              "urn:cspace:c.core.collectionspace.org:orgauthorities:name(organization):item:name(Cuckoo1599463786824)'Cuckoo'",
              ""
            ],
            [
              "urn:cspace:c.core.collectionspace.org:personauthorities:name(person):item:name(Gomongo1599463746195)'Gomongo'",
              "urn:cspace:c.core.collectionspace.org:orgauthorities:name(organization):item:name(Cuckoo1599463786824)'Cuckoo'"
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
            "measurementMethod" => "sliding_calipers^^theodolite_total_station^^electronic_distance_measurement^^measuring_tape_cloth",
            "value" => "25^^83^^56^^10",
            "measurementUnit" => "centimeters^^carats^^kilograms^^inches",
            "valueQualifier" => "cm^^ct^^kg^^in",
            "valueDate" => "2020-09-23^^2020-09-28^^2020-09-25^^2020-09-30"
          }
        end

        it "combines values properly" do
          result = prepper.prep.response.combined_data[xpath]["measuredBy"]
          expected = [
            [
              "urn:cspace:c.core.collectionspace.org:personauthorities:name(person):item:name(Gomongo1599463746195)'Gomongo'",
              "urn:cspace:c.core.collectionspace.org:personauthorities:name(person):item:name(Comodore1599463826401)'Comodore'",
              "urn:cspace:c.core.collectionspace.org:orgauthorities:name(organization):item:name(Cuckoo1599463786824)'Cuckoo'",
              ""
            ]
          ]
          expect(result).to eq(expected)
        end
      end
    end
  end

  describe "#prep" do
    let(:res) { prepper.prep }
    it "returns self" do
      expect(res).to be_a(CollectionSpace::Mapper::DataPrepper)
    end
    it "response contains orig data hash" do
      expect(res.response.orig_data).not_to be_empty
    end
    it "response contains merged data hash" do
      expect(res.response.merged_data).not_to be_empty
    end
    it "response contains split data hash" do
      expect(res.response.split_data).not_to be_empty
    end
    it "response contains transformed data hash" do
      expect(res.response.transformed_data).not_to be_empty
    end
    it "response contains combined data hash" do
      expect(res.response.combined_data).not_to be_empty
    end
  end

  describe "#check_data" do
    it "returns array" do
      expect(prepper.check_data).to be_a(Array)
    end
  end

  describe "leading/trailing space stripping" do
    let(:datahash) { {"objectNumber" => "123 "} }
    let(:result) { prepper.prep.response.transformed_data["objectnumber"] }

    context "with strip_id_values = true (the default)" do
      it "strips leading/trailing spaces from id field(s)" do
        expect(result).to eq(["123"])
      end
    end

    context "with strip_id_values = false" do
      let(:config) do
        {
          strip_id_values: false
        }
      end

      it "does not strip leading/trailing spaces from id field(s)" do
        expect(result).to eq(["123 "])
      end
    end
  end
end

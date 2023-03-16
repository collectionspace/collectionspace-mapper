# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataHandler do
  let(:client) { core_client }
  let(:cache) { core_cache }
  let(:csid_cache) { core_csid_cache }
  let(:mapperpath) {
    "spec/fixtures/files/mappers/release_6_1/core/"\
      "core_6-1-0_collectionobject.json"
  }
  let(:mapper) { get_json_record_mapper(mapperpath) }
  let(:config) { {delimiter: "|"} }
  let(:handler) do
    CollectionSpace::Mapper::DataHandler.new(record_mapper: mapper,
                                             client: client,
                                             cache: cache,
                                             csid_cache: csid_cache,
                                             config: config)
  end

  # these make services api calls to find terms not in cache
  context "with some terms found and some terms not found",
    services_call: true do
      let(:result) { handler.process(data).terms.reject { |t| t[:found] } }

      context "with terms in instance but not in cache" do
        let(:data) do
          {
            "objectNumber" => "20CS.001.0002",
            # vocabulary, in instance, in cache
            "titleLanguage" => "English",
            # authority, in instance (caseswapped), not in cache
            "namedCollection" => "Test Collection"
          }
        end

        it "returns expected found values" do
          res = handler.process(data)
          not_found = res.terms.reject { |t| t[:found] }
          expect(not_found.length).to eq(0)
        end
      end

      context "with terms in instance but not in cache, and not in instance" do
        let(:data) do
          {
            "objectNumber" => "20CS.001.0001",
            # English is in cache; Klingon is not in instance or cache
            "titleLanguage" => "English| Klingon",
            # In instance (caseswapped)
            "namedCollection" => "Test collection"
          }
        end

        it "returns expected found values" do
          res = handler.process(data)
          not_found = res.terms.reject { |t| t[:found] }
          expect(not_found.length).to eq(1)
        end
      end
    end

  it "tags all un-found terms as such", services_call: true do
    data1 = {
      "objectNumber" => "1",
      # vocabulary - in instance, not in cache
      "publishTo" => "All",
      # authority - in instance, not in cache
      "namedCollection" => "QA TARGET Work"
    }
    data2 = {
      "objectNumber" => "2",
      # vocabulary - now in cache
      "publishTo" => "All",
      # authority - now in cache
      "namedCollection" => "QA TARGET Work",
      # authority - not in instance, not in cache
      "contentConceptAssociated" => "Birbs"
    }

    handler.process(data1)
    result = handler.process(data2).terms.select { |t| t[:found] == false }
    expect(result.length).to eq(1)
  end

  describe "#is_authority" do
    context "anthro profile" do
      let(:client) { anthro_client }
      let(:cache) { anthro_cache }

      context "place record" do
        let(:mapperpath) {
          "spec/fixtures/files/mappers/release_6_1/anthro/"\
            "anthro_4-1-2_place-local.json"
        }

        it "adds a xphash entry for shortIdentifier" do
          result = handler.mapper
            .xpath["places_common"][:mappings]
            .select{ |mapping| mapping.fieldname == "shortIdentifier" }
          expect(result.length).to eq(1)
        end
      end
    end
  end

  describe "#service_type" do
    let(:servicetype) { handler.service_type }

    context "anthro profile" do
      let(:client) { anthro_client }
      let(:cache) { anthro_cache }

      context "collectionobject record" do
        let(:mapperpath) {
          "spec/fixtures/files/mappers/release_6_1/anthro/"\
            "anthro_4-1-2_collectionobject.json"
        }

        it "returns object" do
          expect(servicetype).to eq("object")
        end
      end

      context "place record" do
        let(:mapperpath) {
          "spec/fixtures/files/mappers/release_6_1/anthro/"\
            "anthro_4-1-2_place-local.json"
        }

        it "returns authority" do
          expect(servicetype).to eq("authority")
        end
      end
    end

    context "bonsai profile" do
      let(:client) { bonsai_client }
      let(:cache) { bonsai_cache }

      context "conservation record" do
        let(:mapperpath) {
          "spec/fixtures/files/mappers/release_6_1/bonsai/"\
            "bonsai_4-1-1_conservation.json"
        }

        it "returns procedure" do
          expect(servicetype).to eq("procedure")
        end
      end
    end
  end

  describe "#xpath_hash" do
    let(:result) { handler.mapper.xpath[xpath] }

    context "anthro profile" do
      let(:client) { anthro_client }
      let(:cache) { anthro_cache }

      context "collectionobject record" do
        let(:mapperpath) {
          "spec/fixtures/files/mappers/release_6_1/anthro/"\
            "anthro_4-1-2_collectionobject.json"
        }

        context "xpath ending with commingledRemainsGroup" do
          let(:xpath) {
            "collectionobjects_anthro/commingledRemainsGroupList/"\
              "commingledRemainsGroup"
          }

          it "is_group = true" do
            expect(result[:is_group]).to be true
          end

          it "is_subgroup = false" do
            expect(result[:is_subgroup]).to be false
          end

          it "includes mortuaryTreatment as subgroup" do
            child_xpath = "collectionobjects_anthro/commingledRemainsGroupList"\
              "/commingledRemainsGroup/mortuaryTreatmentGroupList"\
              "/mortuaryTreatmentGroup"
            expect(result[:children]).to eq([child_xpath])
          end
        end

        context "xpath ending with mortuaryTreatmentGroup" do
          let(:xpath) do
            "collectionobjects_anthro/commingledRemainsGroupList/"\
              "commingledRemainsGroup/mortuaryTreatmentGroupList/"\
              "mortuaryTreatmentGroup"
          end

          it "is_group = true" do
            expect(result[:is_group]).to be true
          end

          it "is_subgroup = true" do
            expect(result[:is_subgroup]).to be true
          end

          it "parent is xpath ending with commingledRemainsGroup" do
            ppath = "collectionobjects_anthro/commingledRemainsGroupList/"\
              "commingledRemainsGroup"
            expect(result[:parent]).to eq(ppath)
          end
        end

        context "xpath ending with collectionobjects_nagpra" do
          let(:xpath) { "collectionobjects_nagpra" }

          it "has 5 children" do
            expect(result[:children].size).to eq(5)
          end
        end
      end
    end

    context "bonsai profile" do
      let(:client) { bonsai_client }
      let(:cache) { bonsai_cache }

      context "conservation record" do
        let(:mapperpath) {
          "spec/fixtures/files/mappers/release_6_1/bonsai/"\
            "bonsai_4-1-1_conservation.json"
        }

        context "xpath ending with fertilizersToBeUsed" do
          let(:xpath) {
            "conservation_livingplant/fertilizationGroupList/"\
              "fertilizationGroup/fertilizersToBeUsed"
          }
          it "is a repeating group" do
            expect(result[:is_group]).to be true
          end
        end

        context "xpath ending with conservators" do
          let(:xpath) { "conservation_common/conservators" }
          it "is a repeating group" do
            expect(result[:is_group]).to be false
          end
        end
      end
    end
  end

  describe "#validate" do
    it "returns CollectionSpace::Mapper::Response object" do
      data = {"objectNumber" => "123"}
      result = handler.validate(data)
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end
  end

  describe "#check_fields" do
    let(:result) { handler.check_fields(data) }
    context "bonsai profile" do
      let(:client) { bonsai_client }
      let(:cache) { bonsai_cache }

      context "conservation record" do
        let(:mapperpath) {
          "spec/fixtures/files/mappers/release_6_1/bonsai/"\
            "bonsai_4-1-1_conservation.json"
        }
        let(:data) do
          {
            "conservationNumber" => "123",
            "status" => "good",
            "conservator" => "Someone"
          }
        end

        it "returns expected hash" do
          expected = {
            known_fields: %w[conservationnumber status],
            unknown_fields: %w[conservator]
          }
          expect(result).to eq(expected)
        end
      end
    end
  end

  describe "#prep" do
    let(:data) { {"objectNumber" => "123"} }

    it "can be called with response from validation" do
      vresult = handler.validate(data)
      result = handler.prep(vresult).response
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end

    it "can be called with just data" do
      result = handler.prep(data).response
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end

    context "when response_mode = normal" do
      let(:config) { {response_mode: "normal"} }

      it "returned response includes detailed data transformation info" do
        result = handler.prep(data).response

        expect(result.transformed_data).not_to be_empty
      end
    end

    context "when response_mode = verbose" do
      let(:config) { {response_mode: "verbose"} }

      it "returned response includes detailed data transformation info" do
        result = handler.prep(data).response
        expect(result.transformed_data).not_to be_empty
      end
    end
  end

  describe "#process", services_call: true do
    let(:data) { {"objectNumber" => "123"} }

    it "can be called with response from validation" do
      vresult = handler.validate(data)
      result = handler.process(vresult)
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end

    it "can be called with just data" do
      result = handler.process(data)
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end

    context "when response_mode = normal" do
      it "returned response omits detailed data transformation info" do
        result = handler.process(data)
        expect(result.transformed_data).to be_empty
      end
    end

    context "when response_mode = verbose" do
      let(:config) { {response_mode: "verbose"} }

      it "returned response includes detailed data transformation info" do
        result = handler.process(data)
        expect(result.transformed_data).not_to be_empty
      end
    end
  end

  describe "#map", services_call: true do
    let(:data) { {"objectNumber" => "123"} }
    let(:prepper) {
      CollectionSpace::Mapper::DataPrepper.new(data, handler.searcher, handler)
    }
    let(:prepped) { handler.prep(data).response }
    let(:result) { handler.map(prepped, prepper.xphash) }

    it "returns CollectionSpace::Mapper::Response object" do
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end

    it "Response doc attribute is a Nokogiri XML Document" do
      expect(result.doc).to be_a(Nokogiri::XML::Document)
    end
    context "when response_mode = normal" do
      it "returned response omits detailed data transformation info" do
        expect(result.transformed_data).to be_empty
      end
    end
    context "when response_mode = verbose" do
      let(:config) { {"response_mode" => "verbose"} }
      it "returned response includes detailed data transformation info" do
        expect(result.transformed_data).not_to be_empty
      end
    end
  end
end

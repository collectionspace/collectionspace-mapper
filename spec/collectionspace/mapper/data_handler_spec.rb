# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataHandler do
  subject(:handler){ CollectionSpace::Mapper.data_handler }

  before do
    setup_handler(
      mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
        "core_6-1-0_collectionobject.json"
    )
    CollectionSpace::Mapper.config.batch.delimiter = '|'
  end
  after{ CollectionSpace::Mapper.reset_config }

  describe '#process' do
    let(:processed){ handler.process(data) }

    context "with some terms found and some terms not found" do
      let(:result) { processed.terms.reject { |t| t[:found] } }

      vcr_found_opts = {
        cassette_name: "datahandler_uncached_found_terms",
        record: :new_episodes
      }
      context "with terms in instance but not in cache",
        vcr: vcr_found_opts do
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
            expect(result.length).to eq(0)
          end
        end

      vcr_unfound_opts = {
        cassette_name: "datahandler_uncached_unfound_terms",
        record: :new_episodes
      }
      context "with terms in instance but not in cache, and not in instance",
        vcr: vcr_unfound_opts do
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
            expect(result.length).to eq(1)
          end
        end
    end

    unfound_term_opts = {
      cassette_name: "datahandler_tag_unfound_terms",
      record: :new_episodes
    }
    it "tags all un-found terms as such", vcr: unfound_term_opts do
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
  end

  describe "#is_authority" do
    before do
      setup_handler(
        profile: 'anthro',
        mapper_path: "spec/fixtures/files/mappers/release_6_1/anthro/"\
          "anthro_4-1-2_place-local.json"
      )
      CollectionSpace::Mapper.config.batch.delimiter = '|'
    end

    it "adds a xphash entry for shortIdentifier" do
      handler
      result = CollectionSpace::Mapper.recordmapper
        .xpath["places_common"][:mappings]
        .select { |mapping| mapping.fieldname == "shortIdentifier" }
      expect(result.length).to eq(1)
    end
  end



  describe "#service_type" do
    let(:servicetype) { handler.service_type }

    context "when anthro collectionobject" do
      before do
        setup_handler(
          profile: 'anthro',
          mapper_path: "spec/fixtures/files/mappers/release_6_1/anthro/"\
            "anthro_4-1-2_collectionobject.json"
        )
      end

      it "returns object" do
        expect(servicetype).to eq("object")
      end
    end

    context "when anthro place" do
      before do
        setup_handler(
          profile: 'anthro',
          mapper_path: "spec/fixtures/files/mappers/release_6_1/anthro/"\
            "anthro_4-1-2_place-local.json"
        )
      end

      it "returns authority" do
        expect(servicetype).to eq("authority")
      end
    end


    context "with bonsai conservation" do
      before do
        setup_handler(
          profile: 'bonsai',
          mapper_path: "spec/fixtures/files/mappers/release_6_1/bonsai/"\
            "bonsai_4-1-1_conservation.json"
        )
      end

      it "returns procedure" do
        expect(servicetype).to eq("procedure")
      end
    end
  end

  describe "#xpath_hash" do
    let(:result){ CollectionSpace::Mapper.recordmapper.xpath[xpath] }

    context "with anthro collectionobject" do
      before do
        setup_handler(
          profile: 'anthro',
          mapper_path: "spec/fixtures/files/mappers/release_6_1/anthro/"\
            "anthro_4-1-2_collectionobject.json"
        )
      end

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

    context "with bonsai conservation" do
      before do
        setup_handler(
          profile: 'bonsai',
          mapper_path: "spec/fixtures/files/mappers/release_6_1/bonsai/"\
            "bonsai_4-1-1_conservation.json"
        )
      end

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

  describe "#validate" do
    it "returns CollectionSpace::Mapper::Response object" do
      data = {"objectNumber" => "123"}
      result = handler.validate(data)
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end
  end

  describe "#check_fields" do
    before do
      setup_handler(
        profile: 'bonsai',
        mapper_path: "spec/fixtures/files/mappers/release_6_1/bonsai/"\
          "bonsai_4-1-1_conservation.json"
      )
    end
    let(:result) { handler.check_fields(data) }
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

    it "returned response includes detailed data transformation info" do
      result = handler.prep(data).response

      expect(result.transformed_data).not_to be_empty
    end

    context "when response_mode = verbose" do
      before do
        setup_handler(
          mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
            "core_6-1-0_collectionobject.json"
        )
        CollectionSpace::Mapper.config.batch.response_mode = 'verbose'
      end

      it "returned response includes detailed data transformation info" do
        result = handler.prep(data).response
        expect(result.transformed_data).not_to be_empty
      end
    end
  end

  describe "#process", vcr: "datahandler_process_and_map" do
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

    it "returned response omits detailed data transformation info" do
      result = handler.process(data)
      expect(result.transformed_data).to be_empty
    end

    context "when response_mode = verbose" do
      before do
        setup_handler(
          mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
            "core_6-1-0_collectionobject.json"
        )
        CollectionSpace::Mapper.config.batch.response_mode = 'verbose'
      end

      it "returned response includes detailed data transformation info" do
        result = handler.process(data)
        expect(result.transformed_data).not_to be_empty
      end
    end
  end

  describe "#map", vcr: "datahandler_process_and_map" do
    let(:data) { {"objectNumber" => "123"} }
    let(:prepper){ CollectionSpace::Mapper.prepper_class.new(data) }
    let(:prepped) { handler.prep(data).response }
    let(:result) { handler.map(prepped, prepper.xphash) }

    it "returns CollectionSpace::Mapper::Response object" do
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end

    it "Response doc attribute is a Nokogiri XML Document" do
      expect(result.doc).to be_a(Nokogiri::XML::Document)
    end

    it "returned response omits detailed data transformation info" do
      expect(result.transformed_data).to be_empty
    end

    context "when response_mode = verbose" do
      before do
        setup_handler(
          mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
            "core_6-1-0_collectionobject.json"
        )
        CollectionSpace::Mapper.config.batch.response_mode = 'verbose'
      end

      it "returned response includes detailed data transformation info" do
        expect(result.transformed_data).not_to be_empty
      end
    end
  end
end

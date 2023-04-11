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
    before do
      setup_handler(
        mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
          "core_6-1-0_collectionobject.json"
      )
      CollectionSpace::Mapper.config.batch.response_mode = "normal"
    end

    let(:data) do
      CollectionSpace::Mapper::Response.new({"objectNumber" => "123"})
    end

    it "can be called with response from validation" do
      vresult = handler.validate(data)
      result = handler.process(vresult)
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
    before do
      setup_handler(
        mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
          "core_6-1-0_collectionobject.json"
      )
    end

    let(:data) { {"objectNumber" => "123"} }
    let(:prepper){ CollectionSpace::Mapper.prepper_class.new(data) }
    let(:prepped) { handler.prep(data).response }
    let(:result) { handler.map(prepped) }

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

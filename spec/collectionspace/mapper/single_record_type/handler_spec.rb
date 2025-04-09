# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::SingleRecordType::Handler do
  subject(:handler) do
    setup_single_record_type_handler(
      profile: profile,
      mapper: mapper,
      config: config
    )
  end

  let(:profile) { "core" }
  let(:mapper) do
        "https://raw.githubusercontent.com/collectionspace/"\
          "cspace-config-untangler/refs/heads/main/data/mappers/"\
          "community_profiles/release_8_1_1_newstyle/core/"\
          "core_10-0-2_group.json"
      end
  let(:config) { {} }

  describe "#service_type", vcr: "core_group_10-0-2" do
    let(:servicetype) { handler.service_type }

    context "when core group" do
      let(:mapper) do
        "https://raw.githubusercontent.com/collectionspace/"\
          "cspace-config-untangler/refs/heads/main/data/mappers/"\
          "community_profiles/release_8_1_1_newstyle/core/"\
          "core_10-0-2_group.json"
      end

      it "returns authority" do
        expect(servicetype).to eq("procedure")
      end
    end
  end

  # describe "#validate", vcr: "core_domain_check" do
  #   let(:result) { handler.validate(data) }

  #   context "when given Hash" do
  #     let(:data) { {"objectNumber" => "123"} }

  #     it "returns CollectionSpace::Mapper::Response object" do
  #       expect(result).to be_a(CollectionSpace::Mapper::Response)
  #     end
  #   end

  #   context "when given Response" do
  #     let(:data) do
  #       CollectionSpace::Mapper::Response.new(
  #         {"objectNumber" => "123"},
  #         handler
  #       )
  #     end

  #     it "returns CollectionSpace::Mapper::Response object" do
  #       expect(result).to be_a(CollectionSpace::Mapper::Response)
  #     end
  #   end
  # end

  # describe "#check_fields", vcr: "bonsai_domain_check" do
  #   let(:result) { handler.check_fields(data) }
  #   let(:profile) { "bonsai" }
  #   let(:mapper) { "bonsai_4-1-1_conservation" }
  #   let(:data) do
  #     {
  #       "conservationNumber" => "123",
  #       "status" => "good",
  #       "conservator" => "Someone"
  #     }
  #   end

  #   it "returns expected hash" do
  #     expected = {
  #       known_fields: %w[conservationnumber status],
  #       unknown_fields: %w[conservator]
  #     }
  #     expect(result).to eq(expected)
  #   end
  # end

  # describe "#prep", vcr: "core_domain_check" do
  #   let(:data) { {"objectNumber" => "123"} }

  #   it "can be called with response from validation" do
  #     vresult = handler.validate(data)
  #     result = handler.prep(vresult)
  #     expect(result).to be_a(CollectionSpace::Mapper::Response)
  #   end

  #   it "can be called with just data" do
  #     result = handler.prep(data)
  #     expect(result).to be_a(CollectionSpace::Mapper::Response)
  #   end

  #   it "returned response includes detailed data transformation info" do
  #     result = handler.prep(data)

  #     expect(result.transformed_data).not_to be_empty
  #   end

  #   context "when response_mode = verbose" do
  #     let(:config) { {response_mode: "verbose"} }

  #     it "returned response includes detailed data transformation info" do
  #       result = handler.prep(data)
  #       expect(result.transformed_data).not_to be_empty
  #     end
  #   end
  # end

  # describe "#process", vcr: "datahandler_process_and_map" do
  #   let(:data) do
  #     CollectionSpace::Mapper::Response.new(
  #       {"objectNumber" => "123"},
  #       handler
  #     )
  #   end

  #   it "can be called with response from validation" do
  #     validated = handler.validate(data)
  #     result = handler.process(validated)
  #     expect(result).to be_a(CollectionSpace::Mapper::Response)
  #     expect(result.transformed_data).to be_empty
  #   end

  #   context "when response_mode = verbose" do
  #     let(:config) { {response_mode: "verbose"} }

  #     it "returned response includes detailed data transformation info" do
  #       result = handler.process(data)
  #       expect(result.transformed_data).not_to be_empty
  #     end
  #   end
  # end

  # describe "#map", vcr: "datahandler_process_and_map" do
  #   let(:data) { {"objectNumber" => "123"} }
  #   let(:prepped) { handler.prep(data) }
  #   let(:result) { handler.map(prepped) }

  #   it "returns CollectionSpace::Mapper::Response object" do
  #     expect(result).to be_a(CollectionSpace::Mapper::Response)
  #   end

  #   it "Response doc attribute is a Nokogiri XML Document" do
  #     expect(result.doc).to be_a(Nokogiri::XML::Document)
  #   end

  #   it "returned response omits detailed data transformation info" do
  #     expect(result.transformed_data).to be_empty
  #   end

  #   context "when response_mode = verbose" do
  #     let(:config) { {response_mode: "verbose"} }

  #     it "returned response includes detailed data transformation info" do
  #       expect(result.transformed_data).not_to be_empty
  #     end
  #   end
  # end
end

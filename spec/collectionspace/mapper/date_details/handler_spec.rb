# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DateDetails::Handler do
  include_context "data_mapper"

  subject(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper,
      config: config
    )
  end
  let(:profile) { "core" }
  let(:mapper) { "core_6-1-0_collectionobject" }
  let(:baseconfig) { {"batch_mode" => "date details"} }
  let(:customcfg) { {} }
  let(:config) { baseconfig.merge(customcfg) }

  let(:datahash) { get_datahash(path: datahash_path) }
  let(:data) { CollectionSpace::Mapper::Response.new(datahash, handler) }

  describe "#validate", vcr: "core_domain_check" do
    let(:result) { handler.validate(data) }

    context "when given Hash" do
      let(:datahash_path) do
        "spec/support/datahashes/date_details/object_production_date_2.json"
      end

      it "returns CollectionSpace::Mapper::Response object" do
        expect(result).to be_a(CollectionSpace::Mapper::Response)
      end
    end

    context "when given Response" do
      let(:data) do
        CollectionSpace::Mapper::Response.new(
          {"objectNumber" => "123"},
          handler
        )
      end

      it "returns CollectionSpace::Mapper::Response object" do
        expect(result).to be_a(CollectionSpace::Mapper::Response)
      end
    end
  end

  describe "#check_fields", vcr: "core_datedetail_check_fields" do
    let(:result) { handler.check_fields(datahash) }
    let(:mapper) { "core_7-1-0_citation-local" }

    context "with date fields only" do
      let(:datahash_path) do
        "spec/support/datahashes/date_details/citation_publicationdate_1.json"
      end

      it "returns expected hash" do
        expect(result[:unknown_fields]).to be_empty
        expect(handler.grouped_fields).to be_empty
      end
    end

    context "with date and grouped fields only" do
      let(:datahash_path) do
        "spec/support/datahashes/date_details/citation_publicationdate_2.json"
      end

      it "returns expected hash" do
        expect(result[:unknown_fields]).to be_empty
        expect(handler.grouped_fields.length).to eq(2)
      end
    end
  end

  describe "#process", vcr: "date_detail_datahandler_process_and_map" do
    let(:mapper) { "core_7-1-0_citation-local" }

    context "with date data only" do
      let(:datahash_path) do
        "spec/support/datahashes/date_details/citation_publicationdate_1.json"
      end
      let(:fixture_path) { "date_details/citation_publicationdate_1.xml" }

      it_behaves_like "Mapped"
    end

    context "with date and grouped field data" do
      let(:datahash_path) do
        "spec/support/datahashes/date_details/citation_publicationdate_2.json"
      end
      let(:fixture_path) { "date_details/citation_publicationdate_2.xml" }

      # before { binding.pry }
      it_behaves_like "Mapped"
    end
  end

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
  #     let(:config){ {response_mode: 'verbose'} }

  #     it "returned response includes detailed data transformation info" do
  #       expect(result.transformed_data).not_to be_empty
  #     end
  #   end
  # end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::RecordMapper do
  subject(:record) { handler.record }

  # Building the handler calls the described class and sets the handler settings
  #   we are interested in from it, so we test the handler config
  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper
    )
  end

  let(:profile) { "anthro" }

  describe "#initialize" do
  end

  describe "setting of record options", vcr: "anthro_domain_check" do
    context "when initialized with authority mapper" do
      let(:mapper) { "anthro_4-1-2_citation-local" }
      it "sets as expected" do
        expect(record.recordtype).to eq("citation")
        expect(record.authority_type).to eq("citationauthorities")
        expect(record.authority_subtype).to eq("citation")
        expect(record.service_type_mixin).to eq(
          CollectionSpace::Mapper::Authority
        )
        expect(record.common_namespace).to eq(
          "citations_common"
        )
        expect(record.xml_template).to be_a(
          Nokogiri::XML::Document
        )
        expect(record.mappings).to be_a(
          CollectionSpace::Mapper::ColumnMappings
        )
        expect(record.xpaths).to be_a(
          CollectionSpace::Mapper::Xpaths
        )
      end
    end

    context "when initialized with relationship mapper" do
      let(:mapper) { "anthro_4-1-2_authorityhierarchy" }
      it "sets as expected" do
        expect(record.recordtype).to eq("authorityhierarchy")
        expect(record.service_type_mixin).to eq(
          CollectionSpace::Mapper::Relationship
        )
        expect(record.common_namespace).to eq(
          "relations_common"
        )
      end
    end

    context "when initialized with collectionobject mapper" do
      let(:mapper) { "anthro_4-1-2_collectionobject" }

      it "sets as expected" do
        expect(record.recordtype).to eq("collectionobject")
        expect(record.service_type_mixin).to be_nil
        expect(record.identifier_field).to eq("objectNumber")
        expect(
          record.namespaces.include?("collectionobjects_nagpra")
        ).to be true
      end
    end

    context "when initialized with media mapper" do
      let(:mapper) { "anthro_4-1-2_media" }

      it "sets as expected" do
        expect(record.recordtype).to eq("media")
        expect(record.recordtype_mixin).to eq(
          CollectionSpace::Mapper::Media
        )
      end
    end

    context "when initialized with newstyle mapper" do
      let(:profile) { "core" }
      let(:mapper) { "core_10-0-2_acquisition_newstyle" }

      it "sets as expected" do
        expect(record.recordtype).to eq("acquisition")
      end
    end

    context "when mapper URL is passed" do
      let(:profile) { "core" }
      let(:mapper) do
        "https://raw.githubusercontent.com/collectionspace/"\
          "cspace-config-untangler/refs/heads/main/data/mappers/"\
          "community_profiles/release_8_1_1_newstyle/core/"\
          "core_10-0-2_group.json"
      end

      it "sets as expected" do
        expect(record.recordtype).to eq("group")
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::ColumnMappings,
  vcr: "core_domain_check" do
  subject(:mappings) { handler.record.mappings }

  # Building the handler calls RecordMapper, which calls the described class to
  #   set the handler.record settings, including :mappings. The :mappings
  #   setting is an instance of the described class, so we test the handler
  #   config
  let(:handler) do
    setup_handler(
      mapper: mapper
    )
  end

  context "when initialized from authority RecordMapper" do
    let(:mapper) { "core_7-1-0_citation-local" }

    it "adds shortIdentifier to mappings" do
      expect(mappings.known_columns.include?("shortidentifier")).to be true
    end
  end

  context "when initialized from media RecordMapper" do
    let(:mapper) { "core_7-1-0_media" }

    it "does not add shortIdentifier to mappings" do
      expect(mappings.known_columns.include?("shortidentifier")).to be false
    end

    it "adds mediaFileURI to mappings" do
      expect(mappings.known_columns.include?("mediafileuri")).to be true
    end
  end

  describe "#known_columns" do
    let(:mapper) { "core_7-2-0_collectionobject" }

    it "returns list of downcased datacolumns" do
      expect(mappings.known_columns).to include("objectnumber")
    end
  end

  describe "#required_columns" do
    let(:mapper) { "core_7-1-0_movement" }

    it "returns column mappings for required fields" do
      expected = %w[currentlocationlocationlocal currentlocationlocationoffsite
        currentlocationorganizationlocal currentlocationrefname
        movementreferencenumber].sort
      expect(mappings.required_columns
             .map(&:datacolumn)
             .sort).to eq(expected)
    end
  end

  describe "#<<" do
    let(:mapper) { "core_7-2-0_collectionobject" }

    let(:added_field) do
      {
        fieldname: "addedField",
        namespace: "persons_common",
        data_type: "string",
        xpath: [],
        required: "not in input data",
        repeats: "n",
        in_repeating_group: "n/a",
        datacolumn: "addedfield"
      }
    end

    it "adds a mapping" do
      mappings << added_field
      expect(mappings.known_columns.include?("addedfield")).to be true
    end
  end

  describe "#lookup" do
    let(:mapper) { "core_7-2-0_collectionobject" }

    it "returns ColumnMapping for column name" do
      result = mappings.lookup("numberType").fieldname
      expect(result).to eq("numberType")
    end
  end
end

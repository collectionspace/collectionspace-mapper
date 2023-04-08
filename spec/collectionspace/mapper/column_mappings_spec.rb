# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::ColumnMappings do
  subject(:mappingsobj) do
    recmapper = CollectionSpace::Mapper.recordmapper
      .send(:hash)
    described_class.new(mappings: recmapper[:mappings])
  end

  after{ CollectionSpace::Mapper.reset_config }

  context "when initialized from authority RecordMapper" do
    before do
      setup_handler(
        mapper_path: "spec/fixtures/files/mappers/release_7_1/"\
          "core_7-1-0_citation-local.json"
      )
    end

    it "adds shortIdentifier to mappings" do
      expect(mappingsobj.known_columns.include?("shortidentifier")).to be true
    end
  end

  context "when initialized from non-authority RecordMapper" do
  end

  context "when initialized from media RecordMapper" do
    before do
      setup_handler(
        mapper_path: "spec/fixtures/files/mappers/release_7_1/"\
          "core_7-1-0_media.json"
      )
    end

    it "does not add shortIdentifier to mappings" do
      expect(mappingsobj.known_columns.include?("shortidentifier")).to be false
    end

    it "adds mediaFileURI to mappings" do
      expect(mappingsobj.known_columns.include?("mediafileuri")).to be true
    end
  end

  describe "#known_columns" do
    before do
      setup_handler(
        mapper_path: "spec/fixtures/files/mappers/release_7_1/"\
          "core_7-1-0_collectionobject.json"
      )
    end

    it "returns list of downcased datacolumns" do
      expect(mappingsobj.known_columns).to include('objectnumber')
    end
  end

  describe "#required_columns" do
    before do
      setup_handler(
        mapper_path: "spec/fixtures/files/mappers/release_7_1/"\
          "core_7-1-0_movement.json"
      )
    end

    it "returns column mappings for required fields" do
      expected = %w[currentlocationlocationlocal currentlocationlocationoffsite
                    currentlocationorganizationlocal currentlocationrefname
                    movementreferencenumber].sort
      expect(mappingsobj.required_columns
             .map(&:datacolumn)
             .sort).to eq(expected)
    end
  end

  describe "#<<" do
    before do
      setup_handler(
        mapper_path: "spec/fixtures/files/mappers/release_7_1/"\
          "core_7-1-0_collectionobject.json"
      )
    end

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
      mappingsobj << added_field
      expect(mappingsobj.known_columns.include?("addedfield")).to be true
    end
  end

  describe "#lookup" do
    before do
      setup_handler(
        mapper_path: "spec/fixtures/files/mappers/release_7_1/"\
          "core_7-1-0_collectionobject.json"
      )
    end

    it "returns ColumnMapping for column name" do
      result = mappingsobj.lookup("numberType").fieldname
      expect(result).to eq("numberType")
    end
  end
end

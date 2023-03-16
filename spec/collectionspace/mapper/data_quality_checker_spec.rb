# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataQualityChecker do
  let(:recordmapper) {
    instance_double("CollectionSpace::Mapper::RecordMapper")
  }
  let(:mapping) {
    CollectionSpace::Mapper::ColumnMapping.new(maphash, recordmapper)
  }

  context "when source_type = optionlist" do
    let(:maphash) do
      {
        fieldname: "collection",
        datacolumn: "collection",
        transforms: {},
        source_type: "optionlist",
        opt_list_values: %w[
                            library-collection
                            permanent-collection
                            study-collection
                            teaching-collection
                           ]
      }
    end
    it "returns expected warnings" do
      data = [
        "Permanent Collection", # not a valid option, should return warning
        "%NULLVALUE%", # indicates placeholder blank value, should be skipped
        "permanent-collection", # valid option
        "" # non-placeholder blank value, should be skipped
      ]
      res = CollectionSpace::Mapper::DataQualityChecker.new(
        mapping,
        data
      ).warnings
      expect(res.size).to eq(1)
    end
  end

  context "when datacolumn contains `refname`" do
    context "and source_type = vocabulary" do
      let(:maphash) do
        {
          fieldname: "nagprainventoryname",
          datacolumn: "nagprainventorynamerefname",
          transforms: {},
          source_type: "vocabulary",
          opt_list_values: []
        }
      end
      context "and value is not well-formed refname" do
        it "returns warning" do
          data = [
            "urn:pahma.cspace.berkeley.edu:vocabularies:name("\
              "nagpraPahmaInventoryNames):item:name("\
              "nagpraPahmaInventoryNames01)'AK-Alaska'"
          ]
          res = CollectionSpace::Mapper::DataQualityChecker.new(
            mapping,
            data
          ).warnings
          expect(res.size).to eq(1)
        end
      end
      context "and value is well-formed refname" do
        it "does not return warning" do
          data = [
            "urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name("\
              "nagpraPahmaInventoryNames):item:name("\
              "nagpraPahmaInventoryNames01)'AK-Alaska'"
          ]
          res = CollectionSpace::Mapper::DataQualityChecker.new(
            mapping,
            data
          ).warnings
          expect(res).to be_empty
        end
      end
    end

    context "and source_type = authority" do
      let(:maphash) do
        {
          fieldname: "nagpradetermculture",
          datacolumn: "nagpradetermculturerefname",
          transforms: {},
          source_type: "authority",
          opt_list_values: []
        }
      end
      context "and value is not well-formed refname" do
        it "returns warning" do
          data = [
            "urn:cspace:pahma.cspace.berkeley.edu:orgauthorities:name("\
              "organization):item:name(Chumash1607458832492)'Chumash"
          ]
          res = CollectionSpace::Mapper::DataQualityChecker.new(
            mapping,
            data
          ).warnings
          expect(res.size).to eq(1)
        end
      end
      context "and value is well-formed refname" do
        it "does not return warning" do
          data = [
            "urn:cspace:pahma.cspace.berkeley.edu:orgauthorities:name("\
              "organization):item:name(Chumash1607458832492)'Chumash'"
          ]
          res = CollectionSpace::Mapper::DataQualityChecker.new(
            mapping,
            data
          ).warnings
          expect(res).to be_empty
        end
      end
    end
  end
end

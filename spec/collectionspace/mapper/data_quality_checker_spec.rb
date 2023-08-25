# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataQualityChecker do
  subject(:checker) do
    CollectionSpace::Mapper::DataQualityChecker.new(
      mapping,
      data,
      response
    )
  end

  let(:mapping) {
    CollectionSpace::Mapper::ColumnMapping.new(mapping: maphash)
  }
  let(:response) { double("Response") }

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

    context "with invalid option value" do
      let(:data) { ["Permanent Collection"] }

      it "adds expected warnings" do
        expect(response).to receive(:add_warning)
        checker
      end
    end

    context "with placeholder, empty, and valid values" do
      let(:data) { ["%NULLVALUE%", "", "permanent-collection"] }

      it "does not add warning" do
        expect(response).not_to receive(:add_warning)
        checker
      end
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

      context "and value is mal-formed refname" do
        let(:data) do
          [
            "url:pahma.cspace.berkeley.edu:vocabularies:name("\
              "nagpraPahmaInventoryNames):item:name("\
              "nagpraPahmaInventoryNames01)'AK-Alaska'"
          ]
        end

        it "returns error", skip: "CollectionSpace::RefName not "\
          "failing on parse of malformed refnames. Fix there." do
          expect(response).to receive(:add_error)
          checker
        end
      end

      context "and value is well-formed refname" do
        let(:data) do
          [
            "urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name("\
              "nagpraPahmaInventoryNames):item:name("\
              "nagpraPahmaInventoryNames01)'AK-Alaska'"
          ]
        end

        it "does not return error" do
          expect(response).not_to receive(:add_error)
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

      context "and value is mal-formed refname" do
        let(:data) do
          [
            "urn:cspace:pahma.cspace.berkeley.edu:orgauthorities:name("\
              "organization):item:name(Chumash1607458832492)'Chumash"
          ]
        end

        it "returns error", skip: "CollectionSpace::RefName not "\
          "failing on parse of malformed refnames. Fix there." do
          expect(response).to receive(:add_error)
          checker
        end
      end

      context "and value is well-formed refname" do
        let(:data) do
          [
            "urn:cspace:pahma.cspace.berkeley.edu:orgauthorities:name("\
              "organization):item:name(Chumash1607458832492)'Chumash'"
          ]
        end

        it "does not return error" do
          expect(response).not_to receive(:add_error)
          checker
        end
      end
    end
  end
end

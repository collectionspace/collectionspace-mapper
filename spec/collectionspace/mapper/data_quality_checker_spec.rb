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

  let(:mapping) do
    CollectionSpace::Mapper::ColumnMapping.new(mapping: maphash)
  end
  let(:response) { double("Response") }

  context "when data_type = integer" do
    let(:maphash) do
      {
        fieldname: "age",
        datacolumn: "age",
        transforms: {},
        data_type: "integer",
        source_type: "na",
        opt_list_values: []
      }
    end

    context "with invalid value" do
      let(:data) { ["1,234", "42", "about 42", "%NULLVALUE%"] }

      it "adds expected error" do
        err = {
          category: :invalid_value_for_data_type,
          message: "The age column's data type is "\
            "integer. The following values are not valid "\
            "integers: 1,234|about 42"
        }
        expect(response).to receive(:add_error).with(err).once
        checker
      end
    end

    context "with placeholder, empty, and valid values" do
      let(:data) { ["%NULLVALUE%", "", "42"] }

      it "does not add error" do
        expect(response).not_to receive(:add_error)
        checker
      end
    end
  end

  context "when data_type = float" do
    let(:maphash) do
      {
        fieldname: "anthroownershippriceamount",
        datacolumn: "anthroownershippriceamount",
        transforms: {},
        data_type: "float",
        source_type: "na",
        opt_list_values: []
      }
    end

    context "with invalid value" do
      let(:data) { [["33", "$100.00"], ["1.2", "1,234"]] }

      it "adds expected error" do
        err = {
          category: :invalid_value_for_data_type,
          message: "The anthroownershippriceamount column's data type is "\
            "float. The following values are not valid "\
            "floats: $100.00|1,234"
        }
        expect(response).to receive(:add_error).with(err).once
        checker
      end
    end

    context "with placeholder, empty, and valid values" do
      let(:data) { ["%NULLVALUE%", "", "1.2"] }

      it "does not add error" do
        expect(response).not_to receive(:add_error)
        checker
      end
    end
  end

  context "when data_type = boolean" do
    let(:maphash) do
      {
        fieldname: "nagprareportfiled",
        datacolumn: "nagprareportfiled",
        transforms: {},
        data_type: "boolean",
        source_type: "na",
        opt_list_values: []
      }
    end

    context "with invalid value" do
      let(:data) { [["maybe", "true"], ["n", "on god"]] }

      it "adds expected error" do
        err = {
          category: :invalid_value_for_data_type,
          message: "The nagprareportfiled column's data type is "\
            "boolean. The following values are not valid "\
            "booleans: maybe|n|on god"
        }
        expect(response).to receive(:add_error).with(err).once
        checker
      end
    end

    context "with placeholder, empty, and valid values" do
      let(:data) { ["%NULLVALUE%", "", "false"] }

      it "does not add error" do
        expect(response).not_to receive(:add_error)
        checker
      end
    end
  end

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
      let(:data) { [["%NULLVALUE%", ""], ["permanent-collection"]] }

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

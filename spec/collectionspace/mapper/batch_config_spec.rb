# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::BatchConfig,
  vcr: "core_domain_check" do
  subject(:config) { described_class.new(config: configopt, handler: handler) }

  let(:handler) do
    setup_handler(
      mapper: mapper
    )
  end
  let(:mapper) { "core_6-1-0_group" }

  let(:configstr) do
    '{
        "delimiter": ";",
        "subgroup_delimiter": "^^",
        "response_mode": "verbose",
        "force_defaults": false,
        "check_record_status": true,
        "status_check_method": "client",
        "search_if_not_cached": true,
        "date_format": "month day year",
        "two_digit_year_handling": "literal",
        "transforms": {
          "collection": {
            "special": [
              "downcase_value"
            ],
            "replacements": [{
              "find": " ",
              "replace": "-",
              "type": "plain"
            }]
          }
        },
        "default_values": {
          "publishTo": "DPLA;Omeka",
          "collection": "library-collection"
        }
      }'
  end
  let(:confighash) { JSON.parse(configstr) }
  let(:configopt) { {} }

  describe ".new" do
    context "when initialized with JSON string" do
      let(:configopt) { configstr }

      it "is created" do
        expect(config).to be_a(described_class)
      end
    end

    context "when initialized with Hash" do
      let(:configopt) { confighash }

      it "is created" do
        expect(config).to be_a(described_class)
      end
    end

    context "when initialized with Array" do
      let(:configopt) { [2, 3] }
      it "raises error" do
        expect do
          config
        end.to raise_error(CollectionSpace::Mapper::UnhandledConfigFormatError)
      end
    end

    context "when initialized with invalid setting value" do
      let(:configopt) { {response_mode: "mouthy"} }

      it "records warning and uses default value" do
        config
        msg = "BatchConfig: invalid response_mode value: mouthy.\n"\
          "Value must be one of: normal, verbose\n"\
          "Using default value (normal)"
        expect(handler.batch.response_mode).to eq("normal")
        expect(handler.warnings).to include(msg)
      end
    end

    context "when initialized with invalid setting value" do
      let(:configopt) { {responsemode: "mouthy"} }

      it "records error and does not set value" do
        config
        msg = "BatchConfig: `responsemode` is not a valid "\
          "configuration setting"
        expect(handler.batch.response_mode).to eq("normal")
        expect(handler.errors).to include(msg)
      end
    end

    context "when initialized as object hierarchy" do
      let(:mapper) { "core_6-1-0_objecthierarchy" }

      it "sets special defaults" do
        config
        expect(handler.batch.default_values.length).to eq(3)
      end
    end

    context "when initialized as authority hierarchy" do
      let(:mapper) { "core_6-1-0_authorityhierarchy" }

      it "sets special defaults" do
        config
        expect(
          handler.batch.default_values["relationshiptype"]
        ).to eq("hasBroader")
      end
    end

    context "when initialized as non-hierarchical relationship" do
      let(:mapper) { "core_6-1-0_nonhierarchicalrelationship" }

      it "sets special defaults" do
        config
        expect(
          handler.batch.default_values["relationshiptype"]
        ).to eq("affects")
      end
    end
  end
end

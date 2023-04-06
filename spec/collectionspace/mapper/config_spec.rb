# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Config do
  let(:config) { described_class.new(opts) }
  let(:configstr) do
    '{
        "delimiter": ";",
        "subgroup_delimiter": "^^",
        "response_mode": "verbose",
        "force_defaults": false,
        "check_record_status": true,
        "status_check_method": "client",
        "search_if_not_cached": true,
        "check_terms": true,
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

  context "when initialized with JSON string" do
    let(:opts) { {config: configstr} }

    it "is created" do
      expect(config).to be_a(described_class)
    end
  end

  context "when initialized with Hash" do
    let(:opts) { {config: confighash} }

    it "is created" do
      expect(config).to be_a(described_class)
    end
  end

  context "when initialized with no config specified" do
    let(:config) { described_class.new }
    it "is created" do
      expect(config).to be_a(described_class)
    end
    it "uses default config" do
      expected = described_class::DEFAULT_CONFIG.clone
      expected[:default_values] = {}
      expect(config.hash).to eq(expected)
    end
  end

  context "when initialized with Array" do
    let(:opts) { {config: [2, 3]} }
    it "raises error" do
      expect {
        config
      }.to raise_error(CollectionSpace::Mapper::UnhandledConfigFormatError)
    end
  end

  context "when initialized with invalid response mode" do
    let(:opts) { {config: {response_mode: "mouthy"}} }

    it "warns and uses default response value" do
      msg = "Config: invalid response_mode value: mouthy. "\
        "Using default value (normal)"
      expect_any_instance_of(described_class).to receive(:warn).with(msg)
      expect(config.response_mode).to eq(
        described_class::DEFAULT_CONFIG[:response_mode]
      )
    end
  end

  context "when initialized with invalid status_check_method" do
    let(:opts) { {config: {status_check_method: "chaos"}} }

    it "warns and uses default response value" do
      msg = "Config: invalid status_check_method value: chaos. "\
        "Using default value (client)"
      expect_any_instance_of(described_class).to receive(:warn).with(msg)
      expect(config.status_check_method).to eq(
        described_class::DEFAULT_CONFIG[:status_check_method]
      )
    end
  end

  context "when initialized with invalid two_digit_year_handling" do
    let(:opts) { {config: {two_digit_year_handling: "foo"}} }

    it "warns and uses default response value" do
      msg = "Config: invalid two_digit_year_handling value: foo. "\
        "Using default value (coerce)"
      expect_any_instance_of(described_class).to receive(:warn).with(msg)
      expect(config.two_digit_year_handling).to eq(
        described_class::DEFAULT_CONFIG[:two_digit_year_handling]
      )
    end
  end

  context "when initialized without required config attribute" do
    let(:opts) { {config: {subgroup_delimiter: "|||"}} }
    it "use default response value" do
      expect(config.delimiter).to eq(
        described_class::DEFAULT_CONFIG[:delimiter]
      )
    end
  end

  context "when initialized as object hierarchy" do
    let(:opts) { {record_type: "objecthierarchy"} }
    it "sets special defaults" do
      expect(config.default_values.length).to eq(3)
    end
  end

  context "when initialized as authority hierarchy" do
    let(:opts) { {record_type: "authorityhierarchy"} }
    it "sets special defaults" do
      expect(config.default_values["relationshiptype"]).to eq("hasBroader")
    end
  end

  context "when initialized as non-hierarchical relationship" do
    let(:opts) { {record_type: "nonhierarchicalrelationship"} }
    it "sets special defaults" do
      expect(config.default_values["relationshiptype"]).to eq("affects")
    end
  end

  describe "#hash" do
    let(:expected_hash) do
      {
        delimiter: ";",
        subgroup_delimiter: "^^",
        response_mode: "verbose",
        strip_id_values: true,
        multiple_recs_found: "fail",
        force_defaults: false,
        check_record_status: true,
        status_check_method: "client",
        search_if_not_cached: true,
        check_terms: true,
        date_format: "month day year",
        two_digit_year_handling: "literal",
        transforms: {
          "collection" => {
            special: ["downcase_value"],
            replacements: [{find: " ", replace: "-", type: "plain"}]
          }
        },
        default_values: {
          "publishto" => "DPLA;Omeka",
          "collection" => "library-collection"
        }
      }
    end

    it "returns expected hash" do
      result = described_class.new(config: configstr).hash
      expect(result).to eq(expected_hash)
    end
  end
end

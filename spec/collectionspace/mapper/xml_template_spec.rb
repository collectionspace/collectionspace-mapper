# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::XmlTemplate do
  subject(:template) { described_class.new(docstructure) }

  let(:docstructure) do
    get_json_record_mapper(mapper)["docstructure"]
  end

  describe "#doc" do
    let(:result) { template.doc.to_xml }

    context "with anthro exit" do
      let(:mapper) { "anthro_9-1-0_exit" }

      # rubocop:disable Layout/LineLength
      let(:expected) do
        "<?xml version=\"1.0\"?>\n<document>\n  <exits_common>\n    <methods/>\n    <owners/>\n    <exitAgentGroupList>\n      <exitAgentGroup/>\n    </exitAgentGroupList>\n    <approvalStatusGroupList>\n      <approvalStatusGroup>\n        <approvalStatusNotes/>\n      </approvalStatusGroup>\n    </approvalStatusGroupList>\n  </exits_common>\n</document>\n"
      end
      # rubocop:enable Layout/LineLength

      it "creates template as expected" do
        expect(result).to eq(expected)
      end
    end

    context "with anthro acquisition" do
      let(:mapper) { "anthro_9-1-0_acquisition" }

      # rubocop:disable Layout/LineLength
      let(:expected) do
        "<?xml version=\"1.0\"?>\n<document>\n  <acquisitions_common>\n    <acquisitionDateGroupList/>\n    <acquisitionSources/>\n    <owners/>\n    <approvalGroupList>\n      <approvalGroup/>\n    </approvalGroupList>\n    <acquisitionFundingList>\n      <acquisitionFunding/>\n    </acquisitionFundingList>\n    <fieldCollectionEventNames/>\n  </acquisitions_common>\n</document>\n"
      end
      # rubocop:enable Layout/LineLength

      it "creates template as expected" do
        expect(result).to eq(expected)
      end
    end
  end
end

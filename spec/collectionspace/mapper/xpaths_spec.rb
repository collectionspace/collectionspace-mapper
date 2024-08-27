# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Xpaths do
  subject(:xpaths) { handler.record.xpaths }

  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper
    )
  end

  describe "#for_row" do
    context "when core profile", vcr: "core_domain_check" do
      let(:profile) { "core" }
      let(:mapper) { "core_6-1-0_nonhierarchicalrelationship" }

      it "returns Hash" do
        data = get_datahash(
          path: "spec/support/datahashes/core/nonHierarchicalRelationship1.json"
        )
        result = xpaths.for_row(data)
        expect(result).to be_a(Hash)
      end
    end

    context "when bonsai profile", vcr: "bonsai_domain_check" do
      let(:profile) { "bonsai" }
      let(:mapper) { "bonsai_4-1-1_objectexit" }

      it "removes non-kept mappings" do
        xpath = "objectexit_common/deacApprovalGroupList/deacApprovalGroup"
        data = get_datahash(
          path: "spec/support/datahashes/bonsai/objectexit1.json"
        )
        result = xpaths.for_row(data)
        chk = result[xpath].mappings.map(&:datacolumn)
        expect(chk.include?("deaccessionapprovalindividualrefname")).to be false
      end
    end
  end
end

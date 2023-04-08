# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Xpaths do
  subject(:xpaths){ CollectionSpace::Mapper.record.xpaths }

  after{ CollectionSpace::Mapper.reset_config }

  describe "#for_row" do
    before do
      setup_handler(
        profile: 'bonsai',
        mapper_path: "spec/fixtures/files/mappers/release_6_1/bonsai/"\
          "bonsai_4-1-1_objectexit.json"
      )
    end

    it "removes non-kept mappings" do
      xpath = "objectexit_common/deacApprovalGroupList/deacApprovalGroup"
      keep =
        ["exitnumber",
         "deaccessionapprovalgroup",
         "deaccessionapprovalindividual",
         "deaccessionapprovalstatus",
         "deaccessionapprovaldate",
         "deaccessionapprovalnote",
         "deaccessiondate"]

      result = xpaths.for_row(keep)
      chk = result[xpath].mappings.map(&:datacolumn)
      expect(chk.include?("deaccessionapprovalindividualrefname")).to be false
    end
  end
end

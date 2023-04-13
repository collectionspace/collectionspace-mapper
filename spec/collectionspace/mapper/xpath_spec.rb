# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Xpath do
  subject(:result){ handler.record.xpaths.lookup(path) }

  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper
    )
  end

  context "with anthro collectionobject", vcr: "anthro_domain_check" do
    let(:profile) { 'anthro' }
    let(:mapper){ "anthro_4-1-2_collectionobject" }

    context "xpath ending with commingledRemainsGroup" do
      let(:path) {
        "collectionobjects_anthro/commingledRemainsGroupList/"\
          "commingledRemainsGroup"
      }

      it "is_group = true" do
        expect(result.is_group?).to be true
      end

      it "is_subgroup = false" do
        expect(result.is_subgroup?).to be false
      end

      it "includes mortuaryTreatment as subgroup" do
        child_xpath = "collectionobjects_anthro/commingledRemainsGroupList"\
          "/commingledRemainsGroup/mortuaryTreatmentGroupList"\
          "/mortuaryTreatmentGroup"
        expect(result.children).to eq([child_xpath])
      end
    end

    context "xpath ending with mortuaryTreatmentGroup" do
      let(:path) do
        "collectionobjects_anthro/commingledRemainsGroupList/"\
          "commingledRemainsGroup/mortuaryTreatmentGroupList/"\
          "mortuaryTreatmentGroup"
      end

      it "is_group = true" do
        expect(result.is_group?).to be true
      end

      it "is_subgroup = true" do
        expect(result.is_subgroup?).to be true
      end

      it "parent is xpath ending with commingledRemainsGroup" do
        parent = "collectionobjects_anthro/commingledRemainsGroupList/"\
          "commingledRemainsGroup"
        expect(result.parent).to eq(parent)
      end
    end

    context "xpath ending with collectionobjects_nagpra" do
      let(:path) { "collectionobjects_nagpra" }

      it "has 5 children" do
        expect(result.children.size).to eq(5)
      end
    end
  end

  context "with bonsai profile", vcr: "bonsai_profile_check" do
    let(:profile){ 'bonsai' }

    context "with conservation rectype" do
      let(:mapper){ "bonsai_4-1-1_conservation" }

      context "xpath ending with fertilizersToBeUsed" do
        let(:path) {
          "conservation_livingplant/fertilizationGroupList/"\
            "fertilizationGroup/fertilizersToBeUsed"
        }
        it "is a repeating group" do
          expect(result.is_group?).to be true
        end
      end

      context "xpath ending with conservators" do
        let(:path) { "conservation_common/conservators" }
        it "is a repeating group" do
          expect(result.is_group?).to be false
        end
      end
    end

    describe "#for_row" do
      let(:mapper){ "bonsai_4-1-1_objectexit" }
      let(:path){ "objectexit_common/deacApprovalGroupList/deacApprovalGroup" }
      let(:keep) do
        ["exitnumber",
         "deaccessionapprovalgroup",
         "deaccessionapprovalindividual",
         "deaccessionapprovalstatus",
         "deaccessionapprovaldate",
         "deaccessionapprovalnote",
         "deaccessiondate"]
      end
      let(:keptmappings){ result.for_row(keep).mappings.map(&:datacolumn) }

      it "removes non-kept mappings" do
        expect(
          keptmappings.include?("deaccessionapprovalindividualrefname")
        ).to be false
      end
    end
  end
end

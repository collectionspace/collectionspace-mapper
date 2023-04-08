# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Xpath do
  subject(:result) do
    CollectionSpace::Mapper.record.xpaths
      .lookup(path)
  end

  after{ CollectionSpace::Mapper.reset_config }

  context "with anthro collectionobject" do
    before do
      setup_handler(
        profile: 'anthro',
        mapper_path: "spec/fixtures/files/mappers/release_6_1/anthro/"\
          "anthro_4-1-2_collectionobject.json"
      )
    end

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

  context "with bonsai conservation" do
    before do
      setup_handler(
        profile: 'bonsai',
        mapper_path: "spec/fixtures/files/mappers/release_6_1/bonsai/"\
          "bonsai_4-1-1_conservation.json"
      )
    end

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
    before do
      setup_handler(
        profile: 'bonsai',
        mapper_path: "spec/fixtures/files/mappers/release_6_1/bonsai/"\
          "bonsai_4-1-1_objectexit.json"
      )
    end

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
      expect(keptmappings.include?("deaccessionapprovalindividualrefname")).to be false
    end
  end
end

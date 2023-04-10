# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::ValueTransformer do
  subject(:transformer) { described_class.new(value, transforms) }
  before do
    setup_handler(
      profile: "anthro",
      mapper_path: "spec/fixtures/files/mappers/release_6_1/anthro/"\
        "anthro_4-1-2_collectionobject.json"
    )
  end
  after{ CollectionSpace::Mapper.reset_config }

  describe "#result" do
    let(:result) { transformer.result }

    context "when vocabulary: behrensmeyer" do
      let(:transforms) {
        {vocabulary: "behrensmeyer", special: %w[behrensmeyer_translate]}
      }
      let(:value) { "0" }

      it "returns transformed value for retrieving refname" do
        expect(result).to eq("0 - no cracking or flaking on bone surface")
      end

      context "and replacement transformation specified" do
        let(:transforms) do
          {
            vocabulary: "agerange",
            special: %w[downcase_value],
            replacements: [
              {find: " - ", replace: "-", type: :plain}
            ]
          }
        end

        context "and term given = Adolescent 26 - 75%" do
          let(:value) { "Adolescent 26 - 75%" }

          it "returns replaced value for retriefing refname" do
            expect(result).to eq("adolescent 26-75%")
          end
        end
      end
    end

    context "when multiple replacements" do
      let(:value) { "rice plant" }
      let(:transforms) do
        {
          replacements: [
            {find: "[aeiou]", replace: "y", type: :regexp},
            {find: " ", replace: "%%", type: :plain},
            {find: '(\w)%%(\w)', replace: '\1 \2', type: :regexp}
          ]
        }
      end

      it "does replacements" do
        expect(result).to eq("rycy plynt")
      end
    end
  end
end

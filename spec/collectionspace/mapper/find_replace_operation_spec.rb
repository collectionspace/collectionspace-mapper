# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::FindReplaceOperation do
  let(:operation){ described_class.new(opspec) }

  describe ".create" do
    let(:creator){ described_class.create(opspec) }

    context "given a plain operation" do
      let(:opspec){ {find: " ", replace: "-", type: "plain"} }
      it "returns a FindReplaceOperation" do
        expect(creator).to be_a(CollectionSpace::Mapper::FindReplaceOperation)
      end
    end

    context "given a regex operation" do
      let(:opspec){ {find: '(\d)-A', replace: '\1 A', type: "regex"} }
      it "returns a RegexFindReplaceOperation" do
        expect(creator).to be_a(
          CollectionSpace::Mapper::RegexFindReplaceOperation
        )
      end
    end
  end

  describe "#perform" do
    let(:opspec){ {find: " ", replace: "-", type: "plain"} }
    let(:result){ operation.perform(value) }
    context "given blank value" do
      let(:value){ "" }
      it "returns empty string" do
        expect(result).to eq("")
      end
    end

    context "given value with multiple occurrences of find pattern" do
      let(:value){ "a b c d" }
      it "replaces all of them" do
        expect(result).to eq("a-b-c-d")
      end
    end
  end
end

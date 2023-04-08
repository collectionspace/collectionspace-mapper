# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::FindReplaceTransformer do
  subject(:transformer) { described_class.new(transform: transform) }

  let(:transform) do
    [
      {find: " ", replace: "-", type: "plain"},
      {find: '(\d)-A', replace: '\1 A', type: "regex"}
    ]
  end

  describe "#precedence" do
    it "returns 0" do
      expect(transformer.precedence).to eq(0)
    end
  end

  describe "#transform" do
    let(:result) { transformer.transform(value) }

    context 'given "boo baz1 A"' do
      let(:value) { "boo baz1 A" }
      it 'returns "boo-baz1 A"' do
        expect(result).to eq("boo-baz1 A")
      end
    end

    context "given blank value" do
      let(:value) { "" }
      it 'returns ""' do
        expect(result).to eq("")
      end
    end
  end
end

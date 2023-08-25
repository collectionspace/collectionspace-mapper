# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataSplitter do
  subject(:splitter) { described_class.new(handler) }

  let(:handler) do
    setup_handler(
      mapper: "core_6-1-0_group",
      config: {delimiter: ";", subgroup_delimiter: "^^"}
    )
  end

  describe "#call", vcr: "core_domain_check" do
    let(:result) { splitter.call(data, mode) }

    context "with unsupported mode" do
      let(:mode) { :unknown }
      let(:data) { "a" }

      it "raises error" do
        expect { result }.to raise_error(
          CollectionSpace::Mapper::UnknownSplitterMode, "unknown"
        )
      end
    end

    context "with mode = :simple" do
      let(:mode) { :simple }

      context 'when "a"' do
        let(:data) { "a" }

        it 'returns ["a"]' do
          expect(result).to eq(%w[a])
        end
      end

      context 'when " a"' do
        let(:data) { " a" }

        it 'returns ["a"]' do
          expect(result).to eq(%w[a])
        end
      end

      context 'when "a;b;c"' do
        let(:data) { "a;b;c" }

        it 'returns ["a", "b", "c"]' do
          expect(result).to eq(%w[a b c])
        end
      end

      context 'when ";b;c"' do
        let(:data) { ";b;c" }

        it 'returns ["", "b", "c"]' do
          expect(result).to eq(["", "b", "c"])
        end
      end

      context 'when "a;b;"' do
        let(:data) { "a;b;" }

        it 'returns ["a", "b", ""]' do
          expect(result).to eq(["a", "b", ""])
        end
      end

      context 'when "a;;c"' do
        let(:data) { "a;;c" }

        it 'returns ["a", "", "c"]' do
          expect(result).to eq(["a", "", "c"])
        end
      end
    end

    context "with mode = :subgroup" do
      let(:mode) { :subgroup }

      context 'when "a^^b;c^^d"' do
        let(:data) { "a^^b;c^^d" }

        it 'returns [["a", "b"], ["c", "d"]]' do
          expect(result).to eq([%w[a b], %w[c d]])
        end
      end

      context 'when "a;c"' do
        let(:data) { "a;c" }

        it 'returns [["a"], ["c"]]' do
          expect(result).to eq([%w[a], %w[c]])
        end
      end

      context 'when "a;c^^d"' do
        let(:data) { "a;c^^d" }

        it 'returns [["a"], ["c", "d"]]' do
          expect(result).to eq([%w[a], %w[c d]])
        end
      end

      context 'when "a^^;c^^d"' do
        let(:data) { "a^^;c^^d" }

        it 'returns [["a", ""], ["c", "d"]]' do
          expect(result).to eq([["a", ""], %w[c d]])
        end
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::RowData do
  subject(:row) { described_class.new(data_hash, recmapper) }
  let(:recmapper) { core_object_mapper }
  let(:data_hash) do
    {
      "objectNumber" => "123",
      "comment" => "blah",
      "title" => "The title",
      "titleTranslation" => "La title"
    }
  end

  describe "#columns" do
    let(:result){ row.columns }

    it "returns Array" do
      expect(result).to be_a(Array)
    end
    it "of ColumnValues" do
      expect(result.all? { |col|
               col.is_a?(CollectionSpace::Mapper::ColumnValue)
             }).to be true
    end
    it "2 elements long" do
      expect(result.length).to eq(4)
    end
  end
end

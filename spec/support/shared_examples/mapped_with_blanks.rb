# frozen_string_literal: true

require "spec_helper"

RSpec.shared_examples "MappedWithBlanks" do
  it "maps correctly" do
    expect(mapped_doc).to match_doc(fixture_path, handler, blanks: :keep)
  end
end

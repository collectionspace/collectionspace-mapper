# frozen_string_literal: true

require "spec_helper"

RSpec.shared_examples "Mapped" do
  it "maps correctly" do
    expect(mapped_doc).to match_doc(fixture_path, handler)
  end
end

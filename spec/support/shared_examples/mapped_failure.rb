# frozen_string_literal: true

require "spec_helper"

RSpec.shared_examples "MappedFailure" do
  it "maps correctly" do
    expect(mapped_doc).to match_doc(fixture_path, handler, mode: :verbose)
  end
end

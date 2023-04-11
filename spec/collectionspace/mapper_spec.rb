# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper do
  it "has a version number" do
    expect(CollectionSpace::Mapper::VERSION).not_to be nil
  end
end

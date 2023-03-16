# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Vocabularies do
  let(:client) { core_client }
  subject(:vocabs) { described_class.new(client) }

  describe "#by_name" do
    it "returns as expected" do
      expect(vocabs.by_name("Annotation Type")).to be_a(Dry::Monads::Success)
      expect(vocabs.by_name("foo")).to be_a(Dry::Monads::Failure)
      expect(vocabs.by_name("acousticalproperties")).to be_a(
        Dry::Monads::Success
      )
      expect(vocabs.by_name("acousticalProperties")).to be_a(
        Dry::Monads::Success
      )
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Dates::StructuredDateHandler do
  subject(:handler){ described_class.new }
  before do
    setup_handler(
      profile: 'anthro',
      mapper_path: "spec/fixtures/files/mappers/release_6_1/anthro/"\
        "anthro_4-1-2_collectionobject.json"
    )
  end
  after{ CollectionSpace::Mapper.reset_config }

  describe "#ce", vcr: "dates_ce" do
    let(:result) { handler.ce }
    let(:refname) {
      "urn:cspace:#{domain}:vocabularies:name(dateera):item:name(ce)'CE'"
    }

    context "when term is cached" do
      let(:domain) { "c.anthro.collectionspace.org" }
      it "returns expected refname" do
        CollectionSpace::Mapper.termcache
          .put_vocab_term("dateera", "CE", refname)
        expect(result).to eq(refname)
      end
    end

    context "when term is not cached" do
      let(:domain) { "anthro.collectionspace.org" }
      it "returns expected refname" do
        [CollectionSpace::Mapper.termcache,
         CollectionSpace::Mapper.csidcache
        ].each { |c| c.remove_vocab_term("dateera", "CE") }
        expect(result).to eq(refname)
      end
    end
  end
end

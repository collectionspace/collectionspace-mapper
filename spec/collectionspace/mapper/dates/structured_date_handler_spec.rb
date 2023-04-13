# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Dates::StructuredDateHandler do
  subject(:date_handler){ described_class.new(handler) }

  let(:handler) do
    setup_handler(
      profile: 'anthro',
      mapper: "anthro_4-1-2_collectionobject"
    )
  end
  after{ CollectionSpace::Mapper.reset_config }

  describe "#ce", vcr: "dates_ce" do
    let(:result) { date_handler.ce }
    let(:refname) {
      "urn:cspace:#{domain}:vocabularies:name(dateera):item:name(ce)'CE'"
    }

    context "when term is cached" do
      let(:domain) { "c.anthro.collectionspace.org" }
      it "returns expected refname" do
        handler.termcache
          .put_vocab_term("dateera", "CE", refname)
        expect(result).to eq(refname)
      end
    end

    context "when term is not cached" do
      let(:domain) { "anthro.collectionspace.org" }
      it "returns expected refname" do
        [handler.termcache,
         handler.csidcache
        ].each { |c| c.remove_vocab_term("dateera", "CE") }
        expect(result).to eq(refname)
      end
    end
  end
end

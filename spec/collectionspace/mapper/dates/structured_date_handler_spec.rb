# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Dates::StructuredDateHandler do
  subject(:date_handler) { described_class.new(handler) }

  let(:handler) do
    setup_handler(
      profile: "anthro",
      mapper: "anthro_4-1-2_collectionobject"
    )
  end
  after { CollectionSpace::Mapper.reset_config }

  describe "#ce", vcr: "dates_ce" do
    let(:result) { date_handler.ce }
    let(:refname) do
      "urn:cspace:#{domain}:vocabularies:name(dateera):item:name(ce)'CE'"
    end

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
          handler.csidcache].each { |c| c.remove_vocab_term("dateera", "CE") }
        expect(result).to eq(refname)
      end
    end

    context "with single record type handler" do
      let(:handler) do
        setup_single_record_type_handler(
          profile: "anthro",
          mapper: "https://raw.githubusercontent.com/collectionspace/"\
            "cspace-config-untangler/refs/heads/main/data/mappers/"\
            "community_profiles/release_8_1_1/anthro/"\
            "anthro_9-0-0_collectionobject.json"
        )
      end

      context "when term is cached" do
        let(:domain) { "c.anthro.collectionspace.org" }
        it "returns expected refname" do
          handler.cache
            .put_vocab_term("dateera", "CE", refname, "refname")
          expect(result).to eq(refname)
        end
      end

      context "when term is not cached" do
        let(:domain) { "anthro.collectionspace.org" }
        it "returns expected refname" do
          %w[refname csid].each do |type|
            handler.cache.remove_vocab_term("dateera", "CE", type)
          end
          expect(result).to eq(refname)
        end
      end
    end
  end
end

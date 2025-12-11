# frozen_string_literal: true

require "spec_helper"

class TermClass
  attr_accessor :errors

  include CollectionSpace::Mapper::Cacheable

  attr_reader :type, :subtype, :handler, :response
  def initialize(type, subtype, handler)
    @type = type
    @subtype = subtype
    @handler = handler
  end
end

RSpec.describe CollectionSpace::Mapper::Cacheable,
  vcr: "core_domain_check" do
  subject(:term) do
    TermClass.new(termtype, termsubtype, handler)
  end

  let(:handler) do
    setup_handler(
      mapper: "core_6-1-0_collectionobject",
      config: config
    )
  end
  let(:baseconfig) { {delimiter: ";"} }
  let(:customcfg) { {} }
  let(:config) { baseconfig.merge(customcfg) }

  let(:termtype) { "conceptauthorities" }
  let(:termsubtype) { "concept" }

  describe "#in_cache?" do
    let(:result) { term.send(:in_cache?, val) }

    context "when not in cache" do
      let(:val) { "Tiresias" }
      it "returns false" do
        expect(result).to be false
      end
    end

    context "when in cache" do
      let(:val) { "Test" }
      it "returns true" do
        expect(result).to be true
      end
    end

    context "when captitalized form is in cache" do
      let(:val) { "test" }
      it "returns true" do
        expect(result).to be true
      end
    end

    context "with single record type handler" do
      let(:handler) do
        setup_single_record_type_handler(
          mapper: "https://raw.githubusercontent.com/collectionspace/"\
            "cspace-config-untangler/refs/heads/main/data/mappers/"\
            "community_profiles/release_8_1_1/core/"\
            "core_10-0-2_collectionobject.json",
          config: config
        )
      end

      context "when not in cache" do
        let(:val) { "Tiresias" }
        it "returns false" do
          expect(result).to be false
        end
      end

      context "when in cache" do
        let(:val) { "Test" }
        it "returns true" do
          expect(result).to be true
        end
      end

      context "when captitalized form is in cache" do
        let(:val) { "test" }
        it "returns true" do
          expect(result).to be true
        end
      end
    end
  end

  describe "#cached_as_unknown?" do
    let(:result) { term.send(:cached_as_unknown?, val) }
    let(:val) { "blahblahblah" }

    context "when not cached as unknown value" do
      it "returns false" do
        handler.termcache
          .remove("unknownvalue", "#{termtype}/#{termsubtype}", val)
        expect(result).to be false
      end
    end

    context "when cached as unknown value" do
      it "returns true" do
        handler.termcache
          .put("unknownvalue", "#{termtype}/#{termsubtype}", val, nil)
        expect(result).to be true
      end
    end

    context "with single record type handler" do
      let(:handler) do
        setup_single_record_type_handler(
          mapper: "https://raw.githubusercontent.com/collectionspace/"\
            "cspace-config-untangler/refs/heads/main/data/mappers/"\
            "community_profiles/release_8_1_1/core/"\
            "core_10-0-2_collectionobject.json",
          config: config
        )
      end

      context "when not cached as unknown value" do
        it "returns false" do
          handler.cache
            .remove(
              "unknownvalue", "#{termtype}/#{termsubtype}", val, "refname"
            )
          expect(result).to be false
        end
      end

      context "when cached as unknown value" do
        it "returns true" do
          handler.cache
            .put(
              "unknownvalue", "#{termtype}/#{termsubtype}", val, nil, "refname"
            )
          expect(result).to be true
        end
      end
    end
  end

  describe "#cached_term" do
    let(:result) { term.send(:cached_term, val) }

    context "when not in cache" do
      let(:val) { "Tiresias" }
      it "returns nil" do
        expect(result).to be_nil
      end
    end

    context "when in cache" do
      let(:val) { "Test" }
      it "returns refname urn" do
        expected = "urn:cspace:c.core.collectionspace.org:conceptauthorities:"\
          "name(concept):item:name(Test1599650854716)'Test'"
        expect(result).to eq(expected)
      end
    end

    context "when capitalized form is in cache" do
      let(:val) { "test" }
      it "returns refname urn" do
        expected = "urn:cspace:c.core.collectionspace.org:conceptauthorities"\
          ":name(concept):item:name(Test1599650854716)'Test'"
        expect(result).to eq(expected)
      end
    end

    context "with single record type handler" do
      let(:handler) do
        setup_single_record_type_handler(
          mapper: "https://raw.githubusercontent.com/collectionspace/"\
            "cspace-config-untangler/refs/heads/main/data/mappers/"\
            "community_profiles/release_8_1_1/core/"\
            "core_10-0-2_collectionobject.json",
          config: config
        )
      end

      context "when not in cache" do
        let(:val) { "Tiresias" }
        it "returns nil" do
          expect(result).to be_nil
        end
      end

      context "when in cache" do
        let(:val) { "Test" }
        it "returns refname urn" do
          expected = "urn:cspace:c.core.collectionspace.org:"\
            "conceptauthorities:name(concept):item:"\
            "name(Test1599650854716)'Test'"
          expect(result).to eq(expected)
        end
      end

      context "when capitalized form is in cache" do
        let(:val) { "test" }
        it "returns refname urn" do
          expected = "urn:cspace:c.core.collectionspace.org:conceptauthorities"\
            ":name(concept):item:name(Test1599650854716)'Test'"
          expect(result).to eq(expected)
        end
      end
    end
  end
end

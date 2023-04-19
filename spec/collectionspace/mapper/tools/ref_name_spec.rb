# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Tools::RefName do
  let(:handler) do
    setup_handler(
      mapper: "core_6-1-0_group"
    )
  end

  describe ".from_urn" do
    let(:result){ described_class.from_urn(urn) }

    context "with authority urn" do
      let(:urn) do
        "urn:cspace:core.collectionspace.org:personauthorities:name"\
          "(person):item:name(MaryPoole1796320156)'Mary Poole'"
      end

      it "creates new RefName object from urn" do
        expect(result.type).to eq("personauthorities")
        expect(result.subtype).to eq("person")
        expect(result.display_name).to eq("Mary Poole")
        expect(result.identifier).to eq("MaryPoole1796320156")
        expect(result.urn).to eq(urn)
      end
    end

    context "with collectionobject urn" do
      let(:urn) do
        "urn:cspace:core.collectionspace.org:collectionobjects:id"\
          "(9010870e-e323-4beb-b065)'2020.1.1055'"
      end

      it "creates new RefName object from urn" do
        expect(result.type).to eq("collectionobjects")
        expect(result.subtype).to be_nil
        expect(result.identifier).to eq("9010870e-e323-4beb-b065")
        expect(result.display_name).to eq("2020.1.1055")
        expect(result.urn).to eq(urn)
      end
    end

    context "with urn for movement" do
      let(:urn) do
        "urn:cspace:core.collectionspace.org:movements:id"\
          "(8e74756f-38f5-4dee-90d4)"
      end

      it "builds refname from URN" do
        expect(result.type).to eq("movements")
        expect(result.subtype).to be_nil
        expect(result.identifier).to eq("8e74756f-38f5-4dee-90d4")
        expect(result.display_name).to eq("")
        expect(result.urn).to eq(urn)
      end
    end

    context "with unparseable URN" do
      let(:urn){ "urn:cspace:core.collectionspace.org:weird" }
      it "raises error" do
        expect{ result }.to raise_error(
          CollectionSpace::Mapper::UnparseableRefNameUrnError
        )
      end
    end
  end

  describe ".from_term", vcr: "core_domain_check" do
    let(:result){ described_class.from_term(**args) }

    context "with authority data" do
      let(:args) do
        {
          source_type: :authority,
          type: "personauthorities",
          subtype: "person",
          term: "Mary Poole",
          handler: handler
        }
      end

      it "builds refname" do
        refname = "urn:cspace:core.collectionspace.org:personauthorities:name"\
          "(person):item:name(MaryPoole1796320156)'Mary Poole'"
        expect(result.urn).to eq(refname)
      end
    end

    context "with vocabulary data" do
      let(:args) do
        {
          source_type: :vocabulary,
          type: "vocabularies",
          subtype: "annotationtype",
          term: "another term",
          handler: handler
        }
      end

      it "builds refname" do
        refname = "urn:cspace:core.collectionspace.org:vocabularies:name"\
          "(annotationtype):item:name(anotherterm)'another term'"
        expect(result.urn).to eq(refname)
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Tools::RecordStatusServiceCache,
  vcr: "core_domain_check" do
    subject(:service){ handler.status_checker }

    let(:handler) do
      setup_handler(
        profile: profile,
        mapper: mapper,
        config: config
      )
    end
    let(:profile){ "core" }
    let(:config){ {status_check_method: "cache"} }

    describe "#call" do
      let(:result) { service.call(id) }

      context "when mapper is for an authority" do
        let(:mapper){ "core_6-1-0_person-local" }

        context "and result is found" do
          let(:id) { "John Doe" }

          it "status = :existing" do
            expect(result[:status]).to eq(:existing)
          end
          it "sets csid" do
            expect(result[:csid]).to eq("6369-4346-1059-9571")
          end
          it "does not set uri" do
            expect(result[:uri]).to be nil
          end
          it "sets refname" do
            refname = "urn:cspace:c.core.collectionspace.org:personauthorities:"\
              "name(person):item:name(JohnDoe1416422840)'John Doe'"
            expect(result[:refname]).to eq(refname)
          end
        end

        context "and no result is found" do
          let(:id) { "Chickweed Guineafowl" }
          it "status = :new" do
            expect(result[:status]).to eq(:new)
          end
        end
      end

      context "when mapper is for an object" do
        let(:mapper){ "core_6-1-0_collectionobject" }

        context "when object is cached" do
          let(:id) { "Hierarchy Test 001" }

          it "status = existing" do
            expect(result[:status]).to eq(:existing)
          end
        end

        context "when object is not cached" do
          let(:id) { "2000.1" }

          it "status = new" do
            expect(result[:status]).to eq(:new)
          end
        end
      end

      context "when mapper is for a procedure" do
        let(:mapper){ "core_6-1-0_acquisition" }

        context "when cached" do
          let(:id) { "ACQ 123" }

          it "status = existing" do
            expect(result[:status]).to eq(:existing)
          end
        end

        context "when not cached" do
          let(:id) { "foo.bar" }

          it "status = new" do
            expect(result[:status]).to eq(:new)
          end
        end
      end

      context "when mapper is for a hierarchical relationship" do
        let(:mapper){ "core_6-1-0_objecthierarchy" }

        context "when cached" do
          let(:id) do
            {
              sub: "22706401-8328-4778-86fa",
              prd: "hasBroader",
              obj: "8e74756f-38f5-4dee-90d4"
            }
          end

          it "status = existing" do
            expect(result[:status]).to eq(:existing)
          end
        end

        context "when not cached" do
          let(:id) do
            {
              sub: "123",
              prd: "hasBroader",
              obj: "987"
            }
          end

          it "status = new" do
            expect(result[:status]).to eq(:new)
          end
        end
      end

      context "when mapper is for a non-hierarchical relationship" do
        let(:mapper){ "core_6-1-0_nonhierarchicalrelationship" }

        context "when cached" do
          let(:id) do
            {
              sub: "22706401-8328-4778-86fa",
              prd: "affects",
              obj: "8e74756f-38f5-4dee-90d4"
            }
          end

          it "status = existing" do
            expect(result[:status]).to eq(:existing)
          end
        end

        context "when not cached" do
          let(:id) do
            {
              sub: "123",
              prd: "affects",
              obj: "987"
            }
          end

          it "status = new" do
            expect(result[:status]).to eq(:new)
          end
        end
      end
    end
  end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Tools::RecordStatusServiceClient,
  vcr: "core_domain_check" do
  subject(:service) { handler.status_checker }

  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper,
      config: config
    )
  end
  let(:profile) { "core" }
  let(:config) { {} }

  context "when mapper service_path not handled by collectionspace-client" do
    let(:mapper) { "core_6-1-0_aardvark" }

    it "raises NoClientServiceError" do
      expect { handler }.to raise_error(
        CollectionSpace::Mapper::NoClientServiceError
      )
    end
  end

  describe "#call" do
    let(:result) { service.call(id) }

    context "when mapper is for an authority" do
      let(:mapper) { "core_6-1-0_person-local" }

      context "and one result is found",
        vcr: "client_status_svc_auth_lookup_found" do
          let(:id) { "John Doe" }

          it "status = :existing" do
            expect(result[:status]).to eq(:existing)
          end
          it "reports csid" do
            expect(result[:csid]).to eq("775740c2-2484-4194-93f0")
          end
          it "reports uri" do
            expect(result[:uri]).to eq(
              "/personauthorities/0f6cddfa-32ce-4c25-9b2f/items/"\
                "775740c2-2484-4194-93f0"
            )
          end
          it "reports refname" do
            refname = "urn:cspace:core.collectionspace.org:personauthorities:"\
              "name(person):item:name(JohnDoe1416422840)'John Doe'"
            expect(result[:refname]).to eq(refname)
          end
        end

      context "and no result is found",
        vcr: "client_status_svc_auth_lookup_not_found" do
          let(:id) { "Chickweed Guineafowl" }

          it "status = :new" do
            expect(result[:status]).to eq(:new)
          end
        end

      context "and multiple results found",
        vcr: "client_status_svc_auth_lookup_multi_found" do
          let(:id) { "Inkpot Guineafowl" }

          context "with default config" do
            it "raises error" do
              expect { result }.to raise_error(
                CollectionSpace::Mapper::MultipleCsRecordsFoundError,
                "2 matching records found in CollectionSpace. "\
                  "Cannot determine which to update."
              )
            end
          end

          context "with multiple_recs_found = use first in batchconfig" do
            let(:config) { {multiple_recs_found: "use_first"} }

            it "returns result with count of records found" do
              expect(result.keys.any?(:multiple_recs_found)).to be true
            end
          end
        end
    end

    context "when mapper is for an object",
      vcr: "client_status_svc_obj_lookup" do
        let(:mapper) { "core_6-1-0_collectionobject" }
        let(:id) { "2000.1" }

        it "works the same" do
          expect(result[:status]).to eq(:existing)
        end
      end

    context "when mapper is for a procedure",
      vcr: "client_status_svc_proc_lookup" do
        let(:mapper) { "core_6-1-0_acquisition" }
        let(:id) { "2000.001" }

        it "works the same" do
          expect(result[:status]).to eq(:existing)
        end
      end

    context "when mapper is for a relationship",
      vcr: "client_status_svc_rel_lookup" do
        let(:mapper) { "core_6-1-0_objecthierarchy" }
        let(:id) do
          {
            sub: "56c04f5f-32b9-4f1d-8a4b",
            obj: "6f0ce7b3-0130-444d-8633",
            prd: "affects"
          }
        end

        it "works the same" do
          expect(result[:status]).to eq(:existing)
        end
      end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Tools::RecordStatusServiceClient,
  services_call: true do
    let(:client) { core_client }
    let(:service) {
      CollectionSpace::Mapper::Tools::RecordStatusServiceClient.new(client,
        mapper)
    }

    context "when mapper service_path not handled by collectionspace-client" do
      let(:mapper) do
        CollectionSpace::Mapper::RecordMapper.new(
          mapper: get_json_record_mapper(
            "spec/fixtures/files/mappers/core_6-1-0_aardvark.json"
          ),
          termcache: core_cache
        )
      end

      it "raises NoClientServiceError" do
        expect do
          CollectionSpace::Mapper::Tools::RecordStatusServiceClient.new(
            client,
            mapper
          )
        end.to raise_error(CollectionSpace::Mapper::NoClientServiceError)
      end
    end

    # @todo fix these tests so they are not on the now-private method
    describe "#lookup" do
      context "when mapper is for an authority" do
        let(:mapper) do
          CollectionSpace::Mapper::RecordMapper.new(
            mapper: get_json_record_mapper(
              "spec/fixtures/files/mappers/release_6_1/core/"\
                "core_6-1-0_person-local.json"
            ),
            termcache: core_cache
          )
        end

        context "and one result is found",
          vcr: "client_status_svc_auth_lookup_found" do
          let(:report) { service.send(:lookup, "John Doe") }

          it "status = :existing" do
            expect(report[:status]).to eq(:existing)
          end
          it "reports csid" do
            expect(report[:csid]).to eq("775740c2-2484-4194-93f0")
          end
          it "reports uri" do
            expect(report[:uri]).to eq(
              "/personauthorities/0f6cddfa-32ce-4c25-9b2f/items/"\
                "775740c2-2484-4194-93f0"
            )
          end
          it "reports refname" do
            refname = "urn:cspace:core.collectionspace.org:personauthorities:"\
              "name(person):item:name(JohnDoe1416422840)'John Doe'"
            expect(report[:refname]).to eq(refname)
          end
        end

        context "and no result is found",
          vcr: "client_status_svc_auth_lookup_not_found" do
          it "status = :new" do
            res = service.send(:lookup, "Chickweed Guineafowl")
            expect(res[:status]).to eq(:new)
          end
        end

        context "and multiple results found",
          vcr: "client_status_svc_auth_lookup_multi_found" do
          # if these tests fail, verify there are two person/local authority
          #   records for 'Inkpot Guineafowl' in core.dev
          # you may need to re-create them if they have been removed
          context "with default config" do
            it "raises error" do
              expect do
                service.send(:lookup, "Inkpot Guineafowl")
              end.to raise_error(
                CollectionSpace::Mapper::MultipleCsRecordsFoundError
              )
            end
          end

          context "with multiple_recs_found = use first in batchconfig" do
            let(:json) do
              uri = "spec/fixtures/files/mappers/release_6_1/core/"\
                "core_6-1-0_person-local.json"
              get_json_record_mapper(uri)
            end
            let(:mapper) do
              CollectionSpace::Mapper::RecordMapper.new(
                mapper: json,
                batchconfig: {multiple_recs_found: "use_first"}
              )
            end
            let(:result) {
              service.send(:lookup,
                "Inkpot Guineafowl").keys.any?(:multiple_recs_found)
            }
            it "returns result with count of records found" do
              expect(result).to be true
            end
          end
        end
      end

      context "when mapper is for an object",
          vcr: "client_status_svc_obj_lookup" do
        let(:mapper) do
          CollectionSpace::Mapper::RecordMapper.new(
            mapper: get_json_record_mapper(
              "spec/fixtures/files/mappers/release_6_1/core/"\
                "core_6-1-0_collectionobject.json"
            ),
            termcache: core_cache
          )
        end

        it "works the same" do
          res = service.send(:lookup, "2000.1")
          expect(res[:status]).to eq(:existing)
        end
      end

      context "when mapper is for a procedure",
          vcr: "client_status_svc_proc_lookup"  do
        let(:mapper) do
          CollectionSpace::Mapper::RecordMapper.new(
            mapper: get_json_record_mapper(
              "spec/fixtures/files/mappers/release_6_1/core/"\
                "core_6-1-0_acquisition.json"
            ),
            termcache: core_cache
          )
        end

        it "works the same" do
          res = service.send(:lookup, "2000.001")
          expect(res[:status]).to eq(:existing)
        end
      end

      context "when mapper is for a relationship",
          vcr: "client_status_svc_rel_lookup" do
        let(:mapper) do
          CollectionSpace::Mapper::RecordMapper.new(
            mapper: get_json_record_mapper(
              "spec/fixtures/files/mappers/release_6_1/core/"\
                "core_6-1-0_objecthierarchy.json"
            )
          )
        end

        it "works the same" do
          res = service.send(
            :lookup,
            {
              sub: "56c04f5f-32b9-4f1d-8a4b",
              obj: "6f0ce7b3-0130-444d-8633",
              prd: "affects"
            }
          )
          expect(res[:status]).to eq(:existing)
        end
      end
    end
  end

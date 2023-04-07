# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::Tools::RecordStatusServiceClient do
  after{ CollectionSpace::Mapper.reset_config }

  let(:service) {
    CollectionSpace::Mapper::Tools::RecordStatusServiceClient.new
  }

  context "when mapper service_path not handled by collectionspace-client" do
    before do
      setup(
        profile: 'core',
        mapper_path: "spec/fixtures/files/mappers/core_6-1-0_aardvark.json"
      )
    end

    it "raises NoClientServiceError" do
      expect{ service }.to raise_error(
        CollectionSpace::Mapper::NoClientServiceError
      )
    end
  end

  # @todo fix these tests so they are not on the now-private method
  describe "#lookup" do
    let(:result) { service.send(:lookup, str) }

    context "when mapper is for an authority" do
      before do
        setup(
          profile: 'core',
          mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
            "core_6-1-0_person-local.json"
        )
      end

      context "and one result is found",
        vcr: "client_status_svc_auth_lookup_found" do
          let(:str){ 'John Doe' }

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
          let(:str){ "Chickweed Guineafowl" }

          it "status = :new" do
            expect(result[:status]).to eq(:new)
          end
        end

      context "and multiple results found",
        vcr: "client_status_svc_auth_lookup_multi_found" do
          let(:str){ "Inkpot Guineafowl" }

          context "with default config" do
            it "raises error" do
              expect{ result }.to raise_error(
                CollectionSpace::Mapper::MultipleCsRecordsFoundError
              )
            end
          end

          context "with multiple_recs_found = use first in batchconfig" do
            before do
              CollectionSpace::Mapper.config.batch.multiple_recs_found =
                "use_first"
            end

            it "returns result with count of records found" do
              expect(result.keys.any?(:multiple_recs_found)).to be true
            end
          end
        end
    end

    context "when mapper is for an object",
      vcr: "client_status_svc_obj_lookup" do
        before do
          setup(
            profile: 'core',
            mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
              "core_6-1-0_collectionobject.json"
          )
        end
        let(:str){ "2000.1" }

        it "works the same" do
          expect(result[:status]).to eq(:existing)
        end
      end

    context "when mapper is for a procedure",
      vcr: "client_status_svc_proc_lookup" do
        before do
          setup(
            profile: 'core',
            mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
              "core_6-1-0_acquisition.json"
          )
        end
        let(:str){ "2000.001" }

        it "works the same" do
          expect(result[:status]).to eq(:existing)
        end
      end

    context "when mapper is for a relationship",
      vcr: "client_status_svc_rel_lookup" do
        before do
          setup(
            profile: 'core',
            mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
                "core_6-1-0_objecthierarchy.json"
          )
        end
        let(:str) do
          {
            sub: "56c04f5f-32b9-4f1d-8a4b",
            obj: "6f0ce7b3-0130-444d-8633",
            prd: "affects"
          }
        end

        let(:mapper) do
          CollectionSpace::Mapper::RecordMapper.new(
            mapper: get_json_record_mapper(
              "spec/fixtures/files/mappers/release_6_1/core/"\
            )
          )
        end

        it "works the same" do
          expect(result[:status]).to eq(:existing)
        end
      end
  end
end

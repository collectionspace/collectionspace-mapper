# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataValidator do
  let(:config_opts) { {} }
  let(:client) { anthro_client }
  let(:cache) { anthro_cache }
  let(:csid_cache) { anthro_csid_cache }
  let(:mapper) { get_json_record_mapper(mapper_path) }
  let(:recordmapper) do
    CollectionSpace::Mapper::RecordMapper.new(
      mapper: mapper,
      csclient: client,
      termcache: cache,
      csidcache: csid_cache,
      config: config_opts
    )
  end
  let(:validator) { described_class.new(recordmapper, cache) }

  describe ".new" do
    let(:klass) { described_class }

    context "with mapper lacking ID field" do
      it "raises error" do
        mapcfg = instance_double("RecordMapperConfig")
        mappings = instance_double("ColumnMappings")
        mapper = instance_double("RecordMapper")
        allow(mapper).to receive(:config).and_return(mapcfg)
        allow(mapper).to receive(:mappings).and_return(mappings)
        allow(mapcfg).to receive(:identifier_field)
          .and_return(nil)
        allow(mappings).to receive(:required_columns)
          .and_return([])
        expect { klass.new(mapper, cache) }.to raise_error(
          CollectionSpace::Mapper::DataValidator::IdFieldNotInMapperError
        )
      end
    end
  end

  describe "#validate" do
    let(:response) { validator.validate(data) }

    context "with single possible required field (object)" do
      let(:mapper_path) {
        "spec/fixtures/files/mappers/release_6_1/anthro/"\
          "anthro_4-1-2_collectionobject.json"
      }
      let(:data) { {"objectNumber" => "123"} }

      it "returns a CollectionSpace::Mapper::Response" do
        expect(response).to be_a(CollectionSpace::Mapper::Response)
      end
    end

    context "when recordtype has multiple required fields (movement)" do
      let(:mapper_path) {
        "spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_movement.json"
      }

      context "with valid data" do
        let(:data) {
          {"movementReferenceNumber" => "1",
           "currentLocationLocationLocal" => "Loc"}
        }

        it "validates valid data" do
          expect(response.valid?).to be true
        end
      end

      context "with invalid data" do
        let(:data) { {"movementReferenceNumber" => "2"} }

        it "invalidates invalid data" do
          expect(response.valid?).to be false
        end
      end
    end

    context "when recordtype has required field(s)" do
      let(:mapper_path) {
        "spec/fixtures/files/mappers/release_6_1/anthro/"\
          "anthro_4-1-2_collectionobject.json"
      }

      context "and when required field present" do
        context "and required field populated" do
          let(:data) { {"objectNumber" => "123"} }

          it "no required field error returned" do
            err = response.errors.select { |errhash|
              errhash[:type].start_with?("required field")
            }
            expect(err.size).to eq(0)
          end
        end

        context "and required field present but empty" do
          let(:data) { {"objectNumber" => ""} }
          it 'returns required field err w/ msg "required field empty"' do
            err = response.errors.select { |err|
              err.start_with?("required field empty")
            }
            expect(err.size).to eq(1)
          end
        end
      end

      context "when required field not present in data" do
        let(:data) { {"randomField" => "random value"} }
        it 'returns required field error w/msg "required field missing"' do
          err = response.errors.select { |err|
            err.start_with?("required field missing")
          }
          expect(err.size).to eq(1)
        end
      end

      context "when required field provided by defaults (auth hierarchy)" do
        let(:client) { core_client }
        let(:cache) { core_cache }
        let(:csid_cache) { core_csid_cache }
        let(:mapper_path) {
          "spec/fixtures/files/mappers/release_6_1/core/"\
            "core_6-1-0_authorityhierarchy.json"
        }
        let(:data) do
          raw = get_datahash(
            path: "spec/fixtures/files/datahashes/core/authorityHierarchy1.json"
          )
          CollectionSpace::Mapper.setup_data(raw, recordmapper.batchconfig)
        end

        it "no required field error returned", services_call: true do
          err = response.errors.select { |err|
            err.start_with?("required field")
          }
          expect(err.size).to eq(0)
        end
      end
    end

    context "when recordtype has no required field(s)" do
      let(:client) { botgarden_client }
      let(:cache) { botgarden_cache }
      let(:csid_cache) { botgarden_csid_cache }
      let(:mapper_path) {
        "spec/fixtures/files/mappers/release_6_1/botgarden/"\
          "botgarden_2-0-1_loanout.json"
      }

      context "and when record id field present" do
        context "and record id field populated" do
          let(:data) { {"loanOutNumber" => "123"} }

          it "no required field error returned" do
            err = response.errors.select { |err|
              err.start_with?("required field")
            }
            expect(err.size).to eq(0)
          end
        end

        context "and record id field present but empty" do
          let(:data) { {"loanOutNumber" => ""} }

          it 'returns required field error w/msg "required field empty"' do
            err = response.errors.select { |err|
              err.start_with?("required field empty")
            }
            expect(err.size).to eq(1)
          end
        end
      end

      context "when record id field not present in data" do
        let(:data) { {"randomField" => "random value"} }

        it 'returns required field error w/msg "required field missing"' do
          err = response.errors.select { |err|
            err.start_with?("required field missing")
          }
          expect(err.size).to eq(1)
        end
      end
    end
  end
end

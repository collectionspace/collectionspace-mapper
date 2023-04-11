# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataValidator do
  subject(:validator) { described_class.new }

  after{ CollectionSpace::Mapper.reset_config }

  describe ".new" do
    let(:klass) { described_class }

    context "with mapper lacking ID field" do
      before do
        CollectionSpace::Mapper.config.record.identifier_field =
          nil
      end

      it "raises error" do
        expect { validator }.to raise_error(
          CollectionSpace::Mapper::IdFieldNotInMapperError
        )
      end
    end
  end

  describe "#validate" do
    let(:response) do
      to_r = CollectionSpace::Mapper::setup_data(data)
      validator.validate(to_r)
    end

    context "when recordtype has multiple required fields (movement)" do
      before do
        setup_handler(
          mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
            "core_6-1-0_movement.json"
        )
      end

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
      before do
        setup_handler(
          profile: 'anthro',
          mapper_path: "spec/fixtures/files/mappers/release_6_1/anthro/"\
            "anthro_4-1-2_collectionobject.json"
        )
      end

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
        before do
          setup_handler(
            mapper_path: "spec/fixtures/files/mappers/release_6_1/core/"\
              "core_6-1-0_authorityhierarchy.json"
          )
        end

        let(:data) do
          raw = get_datahash(
            path: "spec/fixtures/files/datahashes/core/authorityHierarchy1.json"
          )
          CollectionSpace::Mapper::Response.new(raw)
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
      before do
        setup_handler(
          profile: 'botgarden',
          mapper_path: "spec/fixtures/files/mappers/release_6_1/botgarden/"\
            "botgarden_2-0-1_loanout.json"
        )
      end

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

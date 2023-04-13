# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataValidator do
  subject(:validator) { handler.validator }

  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper,
      config: config
    )
  end
  let(:profile){ 'core' }
  let(:mapper){ "core_6-1-0_collectionobject" }
  let(:config){ {} }

  describe ".new", vcr: "core_domain_check" do
    before{ handler.config.record.identifier_field = nil }
    let(:klass) { described_class.new(handler) }

    context "with mapper lacking ID field" do
      it "raises error" do
        expect { klass }.to raise_error(
          CollectionSpace::Mapper::IdFieldNotInMapperError
        )
      end
    end
  end

  describe "#validate" do
    let(:response) do
      to_r = CollectionSpace::Mapper::Response.new(data, handler)
      validator.validate(to_r)
    end

    context "when recordtype has multiple required fields (movement)",
      vcr: "core_domain_check" do
      let(:mapper){ "core_6-1-0_movement" }

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

    context "when recordtype has required field(s)",
      vcr: "anthro_domain_check" do
      let(:profile){ 'anthro' }
      let(:mapper){ "anthro_4-1-2_collectionobject" }

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

        context "and required field present but empty",
          skip: "unexpected error" do
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
        let(:profile){ 'core' }
        let(:mapper){ "core_6-1-0_authorityhierarchy" }

        let(:data) do
          raw = get_datahash(
            path: "spec/support/datahashes/core/authorityHierarchy1.json"
          )
          CollectionSpace::Mapper::Response.new(raw, handler)
        end

        it "no required field error returned", services_call: true do
          err = response.errors.select { |err|
            err.start_with?("required field")
          }
          expect(err.size).to eq(0)
        end
      end
    end

    context "when recordtype has no required field(s)",
      vcr: "botgarden_domain_check" do
      let(:profile){ 'botgarden' }
      let(:mapper){ "botgarden_2-0-1_loanout" }

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

          it 'returns required field error w/msg "required field empty"',
            skip: "unexpected error" do
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

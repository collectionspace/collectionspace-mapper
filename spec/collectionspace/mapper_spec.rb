# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper do
  it "has a version number" do
    expect(CollectionSpace::Mapper::VERSION).not_to be nil
  end

  describe "#setup_data" do
    context "when passed a CollectionSpace::Mapper::Response" do
      it "returns that Response" do
        response = CollectionSpace::Mapper::Response.new(
          {"objectNumber" => "123"}
        )
        expect(CollectionSpace::Mapper.setup_data(response)).to eq(response)
      end
    end
    context "when passed a Hash" do
      before(:all) do
        @data = {"objectNumber" => "123"}
        @response = CollectionSpace::Mapper.setup_data(@data)
      end
      it "returns CollectionSpace::Mapper::Response with expected orig_data" do
        expect(@response).to be_a(CollectionSpace::Mapper::Response)
        expect(@response.orig_data).to eq(@data)
      end
    end
    context "when passed other class of object" do
      it "returns a CollectionSpace::Mapper::Response" do
        data = %w[objectNumber 123]
        expect do
          CollectionSpace::Mapper.setup_data(data)
        end.to raise_error(
          CollectionSpace::Mapper::UnprocessableDataError,
          "Cannot process a Array. Need a Hash or Mapper::Response"
        )
      end
    end
  end

  describe "#merge_default_values" do
    let(:datahash) do
      {
        "objectNumber" => "123",
        "collection" => "Permanent Collection"
      }
    end
    let(:response) do
      CollectionSpace::Mapper::Response.new(datahash)
    end
    let(:config) { CollectionSpace::Mapper::Config.new }
    let(:result) do
      CollectionSpace::Mapper.merge_default_values(
        response,
        config
      )
    end

    context "when no default_values specified in config" do
      it "does not fall over" do
        res = result.merged_data["collection"]
        ex = "Permanent Collection"
        expect(res).to eq(ex)
      end
    end

    context "when default_values for a field is specified in config" do
      let(:config) do
        CollectionSpace::Mapper::Config.new(config: {
          delimiter: ";",
          default_values: {
            "publishTo" => "DPLA;Omeka"
          }
        })
      end
      context "and no value is given for that field in the incoming data" do
        it "maps the default values" do
          res = result.merged_data["publishto"]
          ex = "DPLA;Omeka"
          expect(res).to eq(ex)
        end
      end
      context "and value is given for that field in the incoming data" do
        let(:datahash) do
          {
            "objectNumber" => "20CS.001.0001",
            "publishto" => "foo"
          }
        end

        context "and :force_defaults = false" do
          it "maps the value in the incoming data" do
            res = result.merged_data["publishto"]
            ex = "foo"
            expect(res).to eq(ex)
          end
        end

        context "and :force_defaults = true" do
          let(:config) do
            CollectionSpace::Mapper::Config.new(config: {
              delimiter: ";",
              default_values: {
                "publishTo" => "DPLA;Omeka"
              },
              force_defaults: true
            })
          end

          it "maps the default value, overwriting value in the incoming data",
            services_call: true do
            res = result.merged_data["publishto"]
            ex = "DPLA;Omeka"
            expect(res).to eq(ex)
          end
        end
      end
    end
  end
end

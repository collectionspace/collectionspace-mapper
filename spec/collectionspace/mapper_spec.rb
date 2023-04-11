# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper do
  it "has a version number" do
    expect(CollectionSpace::Mapper::VERSION).not_to be nil
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

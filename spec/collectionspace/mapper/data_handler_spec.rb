# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataHandler do
  subject(:handler) { described_class.new(**args) }

  describe ".new", vcr: "core_domain_check" do
    context "with vocabulary term config" do
      let(:client) { core_client }
      let(:config) { {"batch_mode" => "vocabulary terms"} }
      let(:args) do
        {
          client: client,
          config: config
        }
      end

      it "returns vocabulary term handler" do
        expect(CollectionSpace::Mapper::VocabularyTerms::Handler).to receive(
          :new
        ).with(client: client)
        handler
      end
    end

    context "with full record signature" do
      let(:mapper) { get_json_record_mapper("core_6-1-0_collectionobject") }
      let(:client) { core_client }
      let(:cache) { core_cache }
      let(:csidcache) { core_csid_cache }

      context "without config" do
        let(:args) do
          {
            record_mapper: mapper,
            client: client,
            cache: cache,
            csid_cache: csidcache
          }
        end

        it "returns full record handler" do
          expect(CollectionSpace::Mapper::HandlerFullRecord).to receive(
            :new
          ).with(**args)
          handler
        end
      end

      context "with empty config" do
        let(:args) do
          {
            record_mapper: mapper,
            client: client,
            cache: cache,
            csid_cache: csidcache,
            config: {}
          }
        end

        it "returns full record handler" do
          expect(CollectionSpace::Mapper::HandlerFullRecord).to receive(
            :new
          ).with(**args)
          handler
        end
      end

      context "with config not setting batch mode" do
        let(:args) do
          {
            record_mapper: mapper,
            client: client,
            cache: cache,
            csid_cache: csidcache,
            config: {delimiter: "|"}
          }
        end

        it "returns full record handler" do
          expect(CollectionSpace::Mapper::HandlerFullRecord).to receive(
            :new
          ).with(**args)
          handler
        end
      end

      context "with config setting batch mode to full record" do
        let(:args) do
          {
            record_mapper: mapper,
            client: client,
            cache: cache,
            csid_cache: csidcache,
            config: {"batch_mode" => "full record"}
          }
        end

        it "returns full record handler" do
          expect(CollectionSpace::Mapper::HandlerFullRecord).to receive(
            :new
          ).with(**args)
          handler
        end
      end

      context "with config setting batch mode to date details" do
        let(:args) do
          {
            record_mapper: mapper,
            client: client,
            cache: cache,
            csid_cache: csidcache,
            config: {"batch_mode" => "date details"}
          }
        end

        it "returns full record handler" do
          expect(CollectionSpace::Mapper::DateDetails::Handler).to receive(
            :new
          ).with(**args)
          handler
        end
      end
    end
  end
end

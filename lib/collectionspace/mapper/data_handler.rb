# frozen_string_literal: true

require "collectionspace/client"
require "collectionspace/refcache"

module CollectionSpace
  module Mapper
    # Interface for calling other data handlers with more specific behavior
    class DataHandler
      class << self
        # @overload new(record_mapper:, client:, cache:, csid_cache:)
        #   No config is given. Returns
        #     {CollectionSpace::Mapper::HandlerFullRecord}
        #   @param record_mapper [Hash, String] parseable JSON string or
        #     already-parsed JSON converted to Hash
        #   @param client [CollectionSpace::Client]
        #   @param cache [CollectionSpace::RefCache] to be used for caching term
        #     refname URNs
        #   @param csid_cache [CollectionSpace::RefCache]
        # @overload new(record_mapper:, client:, cache:, csid_cache:, config:)
        #   Config is given, but is empty, has no `batch_mode` setting, or
        #   `batch_mode` setting is `"full record"`. Returns
        #   {CollectionSpace::Mapper::HandlerFullRecord}
        #   @param record_mapper [Hash, String] parseable JSON string or
        #     already-parsed JSON converted to Hash
        #   @param client [CollectionSpace::Client]
        #   @param cache [CollectionSpace::RefCache] to be used for caching term
        #     refname URNs
        #   @param csid_cache [CollectionSpace::RefCache]
        #   @param config [Hash, String] parseable JSON string or already-
        #     parsed JSON converted to Hash
        # @overload new(client:, config:)
        #   Config is given, has `batch_mode` setting equal to "vocabulary
        #     terms". Returns
        #     {CollectionSpace::Mapper::VocabularyTerms::Handler}
        #   @param client [CollectionSpace::Client]
        #   @param config [Hash, String] parseable JSON string or already-
        #     parsed JSON converted to Hash
        def new(**args)
          ensure_config_is_parsed(args)

          if full_record_args?(args) && full_record_config?(args)
            CollectionSpace::Mapper::HandlerFullRecord.new(**args)
          elsif vocab_term_args?(args) && vocab_term_config?(args)
            CollectionSpace::Mapper::VocabularyTerms::Handler.new(
              client: args[:client]
            )
          elsif full_record_args?(args) && date_details_config?(args)
            CollectionSpace::Mapper::DateDetails::Handler.new(**args)
          else
            fail CollectionSpace::Mapper::UnprocessableHandlerSignature
          end
        end

        private

        def ensure_config_is_parsed(args)
          return if args.keys.none?(:config)
          return if args[:config].respond_to?(:key?)

          args[:config] = JSON.parse(args[:config])
          args
        end

        def full_record_args?(args)
          %i[record_mapper client cache csid_cache].all? do |arg|
            args.key?(arg)
          end
        end

        def full_record_config?(args)
          return true if args.keys.none?(:config)

          cfg = args[:config]
          cfg.empty? ||
            cfg.keys.none?("batch_mode") ||
            cfg["batch_mode"] == "full record"
        end

        def vocab_term_args?(args)
          args.keys.any?(:client)
        end

        def vocab_term_config?(args)
          args.key?(:config) &&
            args[:config].key?("batch_mode") &&
            args[:config]["batch_mode"] == "vocabulary terms"
        end

        def date_details_config?(args)
          return true if args.keys.none?(:config)

          cfg = args[:config]
          cfg.empty? || cfg.dig("batch_mode") == "date details"
        end
      end
    end
  end
end

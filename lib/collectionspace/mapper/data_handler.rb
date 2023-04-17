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
        #     {CollectionSpace::Mapper::FullRecordDataHandler}
        #   @param record_mapper [Hash, String] parseable JSON string or already-
        #     parsed JSON converted to Hash
        #   @param client [CollectionSpace::Client]
        #   @param cache [CollectionSpace::RefCache] to be used for caching term
        #     refname URNs
        #   @param csid_cache [CollectionSpace::RefCache]
        # @overload new(record_mapper:, client:, cache:, csid_cache:, config:)
        #   Config is given, but is empty, has no `batch_mode` setting, or
        #   `batch_mode` setting is `"full record"`. Returns
        #   {CollectionSpace::Mapper::FullRecordDataHandler}
        #   @param record_mapper [Hash, String] parseable JSON string or already-
        #     parsed JSON converted to Hash
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
          if has_full_record_args?(args) && has_full_record_config?(args)
            CollectionSpace::Mapper::FullRecordDataHandler.new(**args)
          elsif has_vocab_term_args?(args) && has_vocab_term_config?(args)
            CollectionSpace::Mapper::VocabularyTerms::Handler.new(
              client: args[:client]
            )
          else
            fail CollectionSpace::Mapper::UnprocessableHandlerSignature
          end
        end

        private

        def has_full_record_args?(args)
          %i[record_mapper client cache csid_cache].all? do |arg|
            args.key?(arg)
          end
        end

        def has_full_record_config?(args)
          args.keys.none?(:config) ||
            args[:config].empty? ||
            args[:config].keys.none?(:batch_mode) ||
            args[:config][:batch_mode] == "full record"
        end

        def has_vocab_term_args?(args)
          args.keys.any?(:client)
        end

        def has_vocab_term_config?(args)
          args.key?(:config) &&
            args[:config].key?(:batch_mode) &&
            args[:config][:batch_mode] == "vocabulary terms"
        end
      end
    end
  end
end

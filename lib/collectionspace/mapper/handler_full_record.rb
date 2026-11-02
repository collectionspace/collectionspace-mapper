# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # Given two caches (CSID and Refname), a RecordMapper hash and a data hash,
    #   returns Response containing CollectionSpace XML document
    class HandlerFullRecord < HandlerAbstractFullRecordAuthVocabCols
      include Dry::Configurable

      # @return [CollectionSpace::Refcache, nil] used to store refnames of
      #   looked-up terms
      setting :termcache, default: nil, reader: true
      # @return [CollectionSpace::Refcache, nil] used to store CSIDs of
      #   looked-up entities
      setting :csidcache, default: nil, reader: true

      private

      def cache_initializer(context)
        config.termcache = eval("cache", context, __FILE__,
          __LINE__ - 1) || new_cache
        config.csidcache = eval("csid_cache", context, __FILE__,
          __LINE__ - 1) || new_cache
      end

      def new_cache
        CollectionSpace::Refcache.new(config: {
          domain: client.domain,
          store: cache,
          lifetime: 10 * 60
        })
      end

      def pre_initialize(context)
        # Defined in subclasses
      end

      def post_initialize(context)
        # Defined in subclasses
      end
    end
  end
end

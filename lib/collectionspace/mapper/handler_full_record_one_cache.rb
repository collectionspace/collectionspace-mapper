# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # given a RecordMapper hash and a data hash, returns CollectionSpace XML
    #   document
    class HandlerFullRecordOneCache < HandlerAbstractFullRecordAuthVocabCols
      include Dry::Configurable

      # @return [CollectionSpace::Refcache, nil] used to store refnames of
      #   looked-up terms and CSIDs of looked-up entities
      setting :cache, default: nil, reader: true

      private

      def pre_initialize(context)
        # Defined in subclasses
      end

      def cache_initializer(context)
        thecache = eval("cache", context, __FILE__, __LINE__)
        config.cache = if thecache.is_a?(CollectionSpace::Refcache)
          thecache
        else
          CollectionSpace::Refcache.new(config: {
            domain: client.domain,
            store: cache,
            lifetime: 10 * 60
          }) # 10 minutes
        end
      end

      def post_initialize(context)
        # Defined in subclasses
      end
    end
  end
end

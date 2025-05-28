# frozen_string_literal: true

require_relative "transformer"

module CollectionSpace
  module Mapper
    # transforms vocabulary term into RefName
    class VocabularyTransformer < Transformer
      def initialize(opts)
        super
        @type = "vocabularies"
        @subtype = opts[:transform]
        # @todo If you get around to implementing this, it needs to support dual
        #   or all-in-one cache
        # @termcache = CollectionSpace::Mapper.termcache
        @csclient = CollectionSpace::Mapper.client
      end

      # @todo implement and test
      def transform(value)
      end
    end
  end
end

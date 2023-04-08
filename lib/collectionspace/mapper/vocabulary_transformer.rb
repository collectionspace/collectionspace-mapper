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
        @termcache = CollectionSpace::Mapper.termcache
        @csclient = CollectionSpace::Mapper.client
      end

      # @todo implement and test
      def transform(value)
      end
    end
  end
end

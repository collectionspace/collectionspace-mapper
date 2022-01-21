# frozen_string_literal: true

require_relative 'transformer'

module CollectionSpace
  module Mapper
    # transforms vocabulary term into RefName
    class VocabularyTransformer < Transformer
      def initialize(opts)
        super
        @type = 'vocabularies'
        @subtype = opts[:transform]
        mapper = opts[:recmapper]
        @termcache = mapper.termcache
        @csclient = mapper.csclient
      end

      def transform(value); end
    end
  end
end

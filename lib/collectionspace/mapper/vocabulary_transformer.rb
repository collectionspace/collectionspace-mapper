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
        @termcache = opts[:recmapper].termcache
        @csclient = opts[:recmapper].csclient
      end

      def transform(value)
      end
    end
  end
end

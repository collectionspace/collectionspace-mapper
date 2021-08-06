# frozen_string_literal: true

require_relative 'transformer'

module CollectionSpace
  module Mapper

    # transforms authority display name into RefName
    class AuthorityTransformer < Transformer

      def initialize(opts)
        super
        @type = opts[:transform][0]
        @subtype = opts[:transform][1]
        @termcache = opts[:recmapper].termcache
        @csclient = opts[:recmapper].csclient
      end

      def transform(value)
      end
    end
  end
end

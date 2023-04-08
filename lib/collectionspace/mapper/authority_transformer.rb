# frozen_string_literal: true

require_relative "transformer"

module CollectionSpace
  module Mapper
    # transforms authority display name into RefName
    class AuthorityTransformer < Transformer
      def initialize(opts)
        super
        @type = opts[:transform][0]
        @subtype = opts[:transform][1]
        @termcache = CollectionSpace::Mapper.termcache
        @csclient = CollectionSpace::Mapper.client
      end

      # @todo implement
      def transform(value)
      end
    end
  end
end

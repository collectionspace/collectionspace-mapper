# frozen_string_literal: true

require_relative 'transformer'

module CollectionSpace
  module Mapper
    # downcases field values
    class DowncaseTransformer < Transformer
      def transform(value); end
    end
  end
end

# frozen_string_literal: true

require_relative 'transformer'

module CollectionSpace
  module Mapper
    # converts date string to CS date stamp
    class DateStampTransformer < Transformer
      def transform(value); end
    end
  end
end

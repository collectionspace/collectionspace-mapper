# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class NullDate
        attr_reader :mappable, :stamp
        def initialize
          @mappable = {}
          @stamp = ''
        end
      end
    end
  end
end


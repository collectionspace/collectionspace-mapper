# frozen_string_literal: true

require 'chronic'

module CollectionSpace
  module Mapper
    module Dates
      extend self

      class CspaceDate
        attr_reader :date_string, :client, :cache, :config, :date_handler, :timestamp, :stamp
        attr_accessor :mappable

        # datehandler is temporary, for testing development
        def initialize(date_string, date_handler)
          @date_handler = date_handler
          @date_string = date_string

          d = date_handler.call(date_string)
          @mappable = d.mappable
          @stamp = d.stamp
        end

        # # currently unused
        # def map(_doc, _parentnode, _groupname)
        #   @parser_result.each do |datefield, value|
        #     value = DateTime.parse(value).iso8601(3).sub('+00:00', 'Z') if datefield['ScalarValue']
        #   end
        # end
      end
    end
  end
end

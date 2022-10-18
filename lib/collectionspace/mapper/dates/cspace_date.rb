# frozen_string_literal: true

require 'chronic'

module CollectionSpace
  module Mapper
    module Dates
      extend self

      class CspaceDate
        attr_reader :date_string, :date_handler, :stamp
        attr_accessor :mappable

        # datehandler is temporary, for testing development
        def initialize(date_string, date_handler)
          @date_handler = date_handler
          @date_string = date_string

          @date = date_handler.call(date_string)
        end

        def mappable
          date.mappable
        end

        def stamp
          date.stamp
        end

        private

        attr_reader :date

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

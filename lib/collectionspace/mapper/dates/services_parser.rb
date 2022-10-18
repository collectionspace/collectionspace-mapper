# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class ServicesParser
        include CollectionSpace::Mapper::Dates::Mappable

        def initialize(date_string, handler)
          @date_string = date_string
          @handler = handler
          self
        end

        def mappable
          response = get_response
          unless response
            fail UnparseableStructuredDateError.new(
              date_string: date_string,
              desc: 'StructuredDate API error or blank response',
              mappable: no_mappable_date
            )
          end

          if response.status_code == 200
            result = response.result['structureddate_common']
            add_timestamp_to_scalar_values(result)
          else
            fail UnparseableStructuredDateError.new(
              date_string: date_string,
              desc: response.parsed,
              mappable: no_mappable_date
            )
          end
        end

        private

        attr_reader :date_string, :handler

        def get_response
          handler.client.get("structureddates?displayDate=#{date_string}")
        rescue
          nil
        end
      end
    end
  end
end

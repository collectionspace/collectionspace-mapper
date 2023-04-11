# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class ServicesParser
        include CollectionSpace::Mapper::Dates::Mappable

        # @param date_string [String] to parse
        def initialize(date_string)
          @date_string = date_string
          @client = CollectionSpace::Mapper.client
        end

        def mappable
          response = get_response
          unless response
            fail CollectionSpace::Mapper::UnparseableStructuredDateError.new(
              date_string: date_string,
              desc: "StructuredDate API error or blank response",
              mappable: no_mappable_date
            )
          end

          if response.status_code == 200
            result = response.result["structureddate_common"]
            add_timestamp_to_scalar_values(result)
          else
            fail CollectionSpace::Mapper::UnparseableStructuredDateError.new(
              date_string: date_string,
              desc: response.parsed,
              mappable: no_mappable_date
            )
          end
        end

        private

        attr_reader :date_string, :client

        def get_response
          client.get("structureddates?displayDate=#{date_string}")
        rescue
          nil
        end
      end
    end
  end
end

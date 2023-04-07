# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class ServicesParser
        include CollectionSpace::Mapper::Dates::Mappable

        # @param date_string [String] to parse
        # @param handler [CollectionSpace::Mapper::Dates::StructuredDateHandler]
        def initialize(
          date_string,
          handler = CollectionSpace::Mapper.date_handler,
          client = CollectionSpace::Mapper.client
        )
          @date_string = date_string
          @handler = handler
          @client = client
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

        attr_reader :date_string, :handler, :client

        def get_response
          client.get("structureddates?displayDate=#{date_string}")
        rescue
          nil
        end
      end
    end
  end
end

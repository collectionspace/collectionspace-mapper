# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      class RecordStatusServiceClient
        include RecordStatusServiceable

        # @param handler [CollectionSpace::Mapper::DataHandler]
        def initialize(handler)
          @handler = handler
          @client = handler.client
          service = get_service
          @search_field = authority? ? service[:term] : service[:field]
          @ns_prefix = service[:ns_prefix]
          @path = service[:path]
          @response_top = client.get_list_types(path)[0]
          @response_nested = client.get_list_types(path)[1]
        end

        # @param id [Hash, String]
        def call(id)
          lookup(id)
        end

        private

        attr_reader :handler, :client, :search_field, :ns_prefix, :path,
          :response_top, :response_nested

        def get_service
          if authority?
            begin
              client.service(
                type: type,
                subtype: subtype
              )
            rescue KeyError
              raise CollectionSpace::Mapper::NoClientServiceError,
                "#{type} > #{subtype}"
            end
          else
            begin
              client.service(type: type)
            rescue KeyError
              raise CollectionSpace::Mapper::NoClientServiceError, type
            end
          end
        end

        # if there are failures in looking up records due to parentheses,
        #   single/double quotes, special characters, etc., this should be
        #   resolved in the collectionspace-client code.
        # Tests in examples/search.rb
        def lookup(value)
          response = get_response(value)

          ct = count_results(response)
          if ct == 0
            reportable_result
          elsif ct == 1
            reportable_result(response.parsed[response_top][response_nested])
          elsif ct > 1
            unless use_first?
              fail CollectionSpace::Mapper::MultipleCsRecordsFoundError,
                ct
            end

            item = response.parsed[response_top][response_nested].first
            num_found = response.parsed[response_top][response_nested].length
            reportable_result(item).merge({multiple_recs_found: num_found})
          end
        end

        def get_response(value)
          response = if ns_prefix == "relations"
            client.find_relation(
              subject_csid: value[:sub],
              object_csid: value[:obj],
              rel_type: value[:prd]
            )
          else
            lookup_non_relationship(value)
          end

          if response && response.result.success?
            response
          elsif response
            raise CollectionSpace::RequestError, response.result.body
          else
            raise CollectionSpace::RequestError,
              "No response from CollectionSpace instance"
          end
        end

        def lookup_non_relationship(value)
          client.find(
            type: type,
            subtype: subtype,
            value: value,
            field: search_field
          )
        end

        def use_first?
          handler.batch.multiple_recs_found == "use_first"
        end

        def count_results(response)
          response.parsed[response_top]["totalItems"].to_i
        end
      end
    end
  end
end

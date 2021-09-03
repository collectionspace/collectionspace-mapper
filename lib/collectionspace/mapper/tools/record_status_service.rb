# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class MultipleCsRecordsFoundError < StandardError
      attr_reader :message
      def initialize(count)
        @message = "#{count} matching records found in CollectionSpace. Cannot determine which to update."
      end
    end

    class NoClientServiceError < StandardError; end
    
    module Tools
      class RecordStatusService
        def initialize(client, mapper)
          @client = client
          @mapper = mapper
          @is_authority = @mapper.config.service_type == 'authority' ? true : false
          service = get_service
          @search_field = @is_authority ? service[:term] : service[:field]
          @ns_prefix = service[:ns_prefix]
          @path = service[:path]
          @response_top = @client.get_list_types(@path)[0]
          @response_nested = @client.get_list_types(@path)[1]
        end

        # if there are failures in looking up records due to parentheses, single/double
        #  quotes, special characters, etc., this should be resolved in the
        #  collectionspace-client code.
        # Tests in examples/search.rb
        def lookup(value)
          if @ns_prefix == 'relations'
            response = lookup_relationship(value)
          else
            response = lookup_non_relationship(value)
          end

          ct = count_results(response)
          if ct == 0
            report = { status: :new }
          elsif ct == 1
            report = {
              status: :existing,
              csid: response.parsed[@response_top][@response_nested]['csid'],
              uri: response.parsed[@response_top][@response_nested]['uri'],
              refname: response.parsed[@response_top][@response_nested]['refName']
            }
          elsif ct > 1
            raise CollectionSpace::Mapper::MultipleCsRecordsFoundError.new(ct)
          end
          report
        end

        private

        def lookup_relationship(value)
          query = { 'sbj' => value[:sub], 'obj' => value[:obj] }
          @client.get(@path, query: query)
        end
        
        def lookup_non_relationship(value)
          @client.find(
            type: @mapper.config.service_path,
            subtype: @mapper.config.authority_subtype,
            value: value,
            field: @search_field
          )
        end
        
        def count_results(response)
          unless response.result.success?
            raise CollectionSpace::RequestError, response.result.body
          end
          response.parsed[@response_top]['totalItems'].to_i
        end

        def get_service
          if @is_authority
            begin
              @client.service(
                type: @mapper.config.authority_type,
                subtype: @mapper.config.authority_subtype
              )
            rescue KeyError
              raise CS::Mapper::NoClientServiceError, "#{@mapper.config.authority_type} > #{@mapper.config.authority_subtype}"
            end
          else
            begin
              @client.service(type: @mapper.config.service_path)
            rescue KeyError
              raise CS::Mapper::NoClientServiceError, @mapper.config.service_path
            end
          end
        end
      end
    end
  end
end

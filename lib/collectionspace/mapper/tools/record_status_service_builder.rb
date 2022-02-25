# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      class RecordStatusServiceBuilder
        class << self
          def call(client, mapper)
            return CS::Mapper::Tools::RecordStatusServiceCache.new(client, mapper) if mapper.csidcache

            CS::Mapper::Tools::RecordStatusServiceClient.new(client, mapper)
          end
        end
        
        def initialize(client, mapper)
          @client = client
          @mapper = mapper
          @is_authority = @mapper.config.service_type == 'authority'
          service = get_service
          @search_field = @is_authority ? service[:term] : service[:field]
          @ns_prefix = service[:ns_prefix]
          @path = service[:path]
          @response_top = @client.get_list_types(@path)[0]
          @response_nested = @client.get_list_types(@path)[1]
        end
      end
    end
  end
end

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

        private

        def get_service
          if @is_authority
            begin
              @client.service(
                type: @mapper.config.authority_type,
                subtype: @mapper.config.authority_subtype
              )
            rescue KeyError
              raise CS::Mapper::NoClientServiceError,
                "#{@mapper.config.authority_type} > #{@mapper.config.authority_subtype}"
            end
          else
            begin
              @client.service(type: @mapper.config.service_path)
            rescue KeyError
              raise CS::Mapper::NoClientServiceError, @mapper.config.service_path
            end
          end
        end

        def get_value_for_record_status(response)
          case @mapper.service_type.to_s
          when 'CollectionSpace::Mapper::Relationship'
            {
              sub: response.combined_data['relations_common']['subjectCsid'][0],
              obj: response.combined_data['relations_common']['objectCsid'][0]
            }
          when 'CollectionSpace::Mapper::Authority'
            response.split_data['termdisplayname'].first
          else
            response.identifier
          end
        end
      end
    end
  end
end

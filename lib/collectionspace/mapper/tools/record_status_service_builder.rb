# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      class RecordStatusServiceBuilder
        class << self
          def call(client, mapper)
            if mapper.batchconfig.status_check_method == 'client'
              CS::Mapper::Tools::RecordStatusServiceClient.new(client, mapper)
            else
              CS::Mapper::Tools::RecordStatusServiceCache.new(mapper)
            end
          end
        end
        
        def initialize(client = nil, mapper)
          @mapper = mapper
          if authority?
            @type = mapper.config.authority_type
            @subtype = mapper.config.authority_subtype
          else
            @type = mapper.config.service_path
          end
        end

        private

        attr_reader :mapper, :type, :subtype

        def authority?
          mapper.config.service_type == 'authority'
        end
        
        # Given Response object, returns the value needed to look up record's status
        # @param response [CollectionSpace::Mapper::Response]
        def get_value_for_record_status(response)
          case mapper.service_type.to_s
          when 'CollectionSpace::Mapper::Relationship'
            {
              sub: response.combined_data['relations_common']['subjectCsid'][0],
              obj: response.combined_data['relations_common']['objectCsid'][0],
              prd: response.combined_data['relations_common']['relationshipType'][0]
            }
          when 'CollectionSpace::Mapper::Authority'
            response.split_data['termdisplayname'].first
          else
            response.identifier
          end
        end

        def reportable_result(item = nil)
          return {status: :new} unless item

          {
            status: :existing,
            csid: item['csid'],
            uri: item['uri'],
            refname: item['refName']
          }
        end

      end
    end
  end
end

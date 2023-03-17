# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      # Mixin module for different types of RecordStatusService
      module RecordStatusServiceable
        private

        def authority?
          mapper.config.service_type == "authority"
        end

        def type
          authority? ? mapper.config.authority_type : mapper.config.service_path
        end

        def subtype
          authority? ? mapper.config.authority_subtype : nil
        end

        # rubocop:disable Layout/LineLength
        # Given Response object, returns the value needed to look up record's
        #   status
        # @param response [CollectionSpace::Mapper::Response]
        # @todo refactor/DRY
        def get_value_for_record_status(response)
          case mapper.config.service_type
          when "relation"
            {
              sub: response.combined_data["relations_common"]["subjectCsid"][0],
              obj: response.combined_data["relations_common"]["objectCsid"][0],
              prd: response.combined_data["relations_common"]["relationshipType"][0]
            }
          when "authority"
            response.split_data["termdisplayname"].first
          else
            response.identifier
          end
        end
        # rubocop:enable Layout/LineLength

        def reportable_result(item = nil)
          return {status: :new} unless item

          {
            status: :existing,
            csid: item["csid"],
            uri: item["uri"],
            refname: item["refName"]
          }
        end
      end
    end
  end
end

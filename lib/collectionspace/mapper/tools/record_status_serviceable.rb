# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      # Mixin module for different types of RecordStatusService
      module RecordStatusServiceable
        private

        def authority?
          CollectionSpace::Mapper.record.service_type == "authority"
        end

        def type
          if authority?
            CollectionSpace::Mapper.record.authority_type
          else
            CollectionSpace::Mapper.record.service_path
          end
        end

        def subtype
          return nil unless authority?

          CollectionSpace::Mapper.record.authority_subtype
        end

        # rubocop:disable Layout/LineLength
        # Given Response object, returns the value needed to look up record's
        #   status
        # @param response [CollectionSpace::Mapper::Response]
        # @todo refactor/DRY
        def get_value_for_record_status(response)
          case CollectionSpace::Mapper.record.service_type
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

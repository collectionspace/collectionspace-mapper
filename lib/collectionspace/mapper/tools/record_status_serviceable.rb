# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      # Mixin module for different types of RecordStatusService
      module RecordStatusServiceable
        private

        def authority?
          handler.record.service_type == "authority"
        end

        def type
          if authority?
            handler.record.authority_type
          else
            handler.record.service_path
          end
        end

        def subtype
          return nil unless authority?

          handler.record.authority_subtype
        end

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

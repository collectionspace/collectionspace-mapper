# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      # Factory to build the appropriate RecordStatusService
      class RecordStatusServiceBuilder
        class << self
          # @param handler [CollectionSpace::Mapper::DataHandler]
          def call(handler)
            class_for(handler).new(handler)
          end

          private

          def class_for(handler)
            chk_method = handler.batch.status_check_method
            matchpoint = handler.batch.record_matchpoint

            if chk_method == "client" && matchpoint == "identifier"
              CollectionSpace::Mapper::Tools::RecordStatusServiceClient
            elsif chk_method == "client" && matchpoint == "uri"
              CollectionSpace::Mapper::Tools::RecordStatusServiceClientUri
            elsif chk_method == "cache"
              CollectionSpace::Mapper::Tools::RecordStatusServiceCache
            end
          end
        end
      end
    end
  end
end

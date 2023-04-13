# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      # Factory to build the appropriate RecordStatusService
      class RecordStatusServiceBuilder
        class << self
          # @param handler [CollectionSpace::Mapper::DataHandler]
          def call(handler)
            if handler.batch.status_check_method == "client"
              CollectionSpace::Mapper::Tools::RecordStatusServiceClient.new(
                handler
              )
            else
              CollectionSpace::Mapper::Tools::RecordStatusServiceCache.new(
                handler
              )
            end
          end
        end
      end
    end
  end
end

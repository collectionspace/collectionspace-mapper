# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      # Factory to build the appropriate RecordStatusService
      class RecordStatusServiceBuilder
        class << self
          def call(
            mapper: CollectionSpace::Mapper.recordmapper,
            client: CollectionSpace::Mapper.client
          )
            if CollectionSpace::Mapper.batch.status_check_method == "client"
              CollectionSpace::Mapper::Tools::RecordStatusServiceClient.new(
                client,
                mapper
              )
            else
              CollectionSpace::Mapper::Tools::RecordStatusServiceCache.new(
                mapper
              )
            end
          end
        end
      end
    end
  end
end

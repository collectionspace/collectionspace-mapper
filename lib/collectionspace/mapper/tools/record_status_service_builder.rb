# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      # Factory to build the appropriate RecordStatusService
      class RecordStatusServiceBuilder
        class << self
          def call
            if CollectionSpace::Mapper.batch.status_check_method == "client"
              CollectionSpace::Mapper::Tools::RecordStatusServiceClient.new
            else
              CollectionSpace::Mapper::Tools::RecordStatusServiceCache.new
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # aggregate representation of transformers associated with a ColumnMapping
    #   (queue)
    # Performs a factory function by creating the appropriate individual
    #   Transformers for a given ColumnMapping based on data_type
    # Also has the logic for how to keep Transformers in the proper order in the
    #   queue. Batch config-specified transformers should be first, followed by
    #   anything else, followed finally by AuthorityTermTransformer or
    #   VocabularyTermTransformer
    class Transformers
      def initialize(colmapping:, transforms:, recmapper:)
        @colmapping = colmapping
        @transforms = transforms
        @recmapper = recmapper
        @queue = []
        populate_queue
      end

      def queue
        @queue.sort
      end

      private

      def populate_queue
        data_type_transforms
        return @queue if @transforms.empty?

        @queue << @transforms.map do |type, transform|
          Transformer.create(type: type, transform: transform,
            recmapper: @recmapper)
        end
        @queue.flatten!
      end

      def data_type_transforms
        if @colmapping.data_type == "date"
          @queue << DateStampTransformer.new
        end
        if @colmapping.data_type == "structured date group"
          @queue << StructuredDateTransformer.new
        end
      end
    end
  end
end

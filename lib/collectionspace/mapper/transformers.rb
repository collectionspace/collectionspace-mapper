# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # @todo Implement in actual processing
    #
    # Aggregate representation of transformers associated with a ColumnMapping
    #   (queue)
    # Performs a factory function by creating the appropriate individual
    #   Transformers for a given ColumnMapping based on data_type
    # Also has the logic for how to keep Transformers in the proper order in the
    #   queue. Batch config-specified transformers should be first, followed by
    #   anything else, followed finally by AuthorityTermTransformer or
    #   VocabularyTermTransformer
    class Transformers
      # @param colmapping [CollectionSpace::Mapper::ColumnMapping]
      # @param transforms [Hash] key is transform type; value is transform
      #   details
      def initialize(colmapping:, transforms:)
        @colmapping = colmapping
        @transforms = transforms
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
          Transformer.create(type: type, transform: transform)
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

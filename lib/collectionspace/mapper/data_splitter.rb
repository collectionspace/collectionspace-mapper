# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataSplitter
      # @param handler [CollectionSpace::Mapper::DataHandler]
      def initialize(handler)
        handler.config.data_splitter = self
        @delim = handler.batch.delimiter
        @sgdelim = handler.batch.subgroup_delimiter
      end

      def call(data, mode)
        case mode
        when :simple
          simple_split(data)
        when :subgroup
          subgroup_split(data)
        else
          fail CollectionSpace::Mapper::UnknownSplitterMode, mode
        end
      end

      private

      attr_reader :delim, :sgdelim

      def simple_split(data)
        data.split(delim, -1).map(&:strip)
      end

      def subgroup_split(data)
        simple_split(data)
          .map do |grp|
            grp.split(sgdelim, -1)
              .map(&:strip)
          end
      end
    end
  end
end

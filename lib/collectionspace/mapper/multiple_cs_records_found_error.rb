# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class MultipleCsRecordsFoundError < StandardError
      attr_reader :message

      def initialize(count)
        @message = "#{count} matching records found in CollectionSpace. "\
          "Cannot determine which to update."
      end
    end
  end
end

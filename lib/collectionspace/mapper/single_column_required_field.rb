# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class SingleColumnRequiredField < RequiredField
      def initialize(fieldname, datacolumns)
        super
      end

      def present_in?(data)
        super
      end

      def populated_in?(data)
        super
      end

      def missing_message
        "required field missing: #{@columns[0]} must be present"
      end

      def empty_message
        "required field empty: #{@columns[0]} must be populated"
      end
    end
  end
end

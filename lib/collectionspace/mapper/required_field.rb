# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class RequiredField
      def initialize(fieldname, datacolumns)
        @field = fieldname.downcase
        @columns = datacolumns.map(&:downcase)
      end

      def present_in?(data)
        present = data.keys.map(&:downcase) & @columns
        present.any?
      end

      def populated_in?(data)
        data = data.transform_keys(&:downcase)
        values = @columns.map{ |column| data[column] }.reject(&:blank?)
        values.any?
      end
    end
  end
end

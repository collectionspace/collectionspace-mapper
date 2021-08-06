# frozen_string_literal: true

module CollectionSpace
  module Mapper

    # a single find/replace operation -- one step in a FindReplaceTransformer
    class FindReplaceOperation
      def initialize(opts)
        @find = opts[:find]
        @replace = opts[:replace]
      end

      def perform(value)
        return value if value.blank?

        value.gsub(@find, @replace)
      end

      def self.create(opts)
        case opts[:type]
        when 'plain'
          self.new(opts)
        when 'regex'
          RegexFindReplaceOperation.new(opts)
        end
      end
    end
  end
end

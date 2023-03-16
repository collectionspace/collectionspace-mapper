# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class UnknownTerm
      class ReconstituteNilError < CollectionSpace::Mapper::Error
        def initialize
          msg = "Cannot reconstitute from NilValue"
          super(msg)
        end
      end

      # Reconstitute UnknownTerm object from cached string
      # @param str [String] of form: type|||subtype|||term
      def self.from_string(str)
        fail(ReconstituteNilError.new) if str.nil?

        parts = str.split("|||")
        new(type: parts[0], subtype: parts[1], term: parts[2])
      end

      attr_reader :type, :subtype, :identifier, :display_name, :urn

      def initialize(type:, subtype:, term:)
        @type = type
        @subtype = subtype
        @display_name = term
        @identifier = term
        # Named "urn" to be used the same way as CollectionSpace::Mapper::Tools::RefName
        # This value gets cached and can be reconstituted into an UnknownTerm object
        @urn = "#{type}|||#{subtype}|||#{term}"
      end

      def key
        "#{type}-#{subtype}-#{display_name}"
      end
    end
  end
end

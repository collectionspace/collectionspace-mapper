# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class Response
      attr_reader :orig_data
      attr_accessor :split_data, :merged_data, :transformed_data, :combined_data, :doc, :errors, :warnings,
                    :identifier, :terms, :record_status, :csid, :uri, :refname
      def initialize(data_hash)
        @orig_data = data_hash
        @merged_data = {}
        @split_data = {}
        @transformed_data = {}
        @combined_data = {}
        @doc = nil
        @errors = []
        @warnings = []
        @terms = []
        @identifier = ''
      end

      def valid?
        @errors.empty? ? true : false
      end

      def normal
        @merged_data = {}
        @split_data = {}
        @transformed_data = {}
        @combined_data = {}
        self
      end

      def xml
        doc ? doc.to_xml : nil
      end
    end
  end
end


# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class Response
      attr_reader :orig_data
      attr_accessor :split_data, :merged_data, :transformed_data,
        :combined_data, :doc, :errors, :warnings, :identifier, :terms,
        :record_status, :csid, :uri, :refname, :xphash

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
        @identifier = ""
      end

      def add_warning(warning)
        warnings << warning
      end

      def add_xphash(hash)
        @xphash = hash
      end

      def merge_status_data(status_data)
        @record_status = status_data[:status]
        @csid = status_data[:csid]
        @uri = status_data[:uri]
        @refname = status_data[:refname]
      end

      def valid?
        @errors.empty?
      end

      def normal
        @merged_data = {}
        @split_data = {}
        @transformed_data = {}
        @combined_data = {}
        self
      end

      def xml
        doc&.to_xml
      end

      def add_multi_rec_found_warning(num_found)
        msg = "#{num_found} records found for #{identifier}. Using first "\
          "record found: #{uri}"
        warnings << {
          category: :multiple_records_found_for_id,
          field: nil,
          type: nil,
          subtype: nil,
          value: nil,
          message: msg
        }
      end
    end
  end
end

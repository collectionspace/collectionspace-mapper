# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class Response
      attr_reader :orig_data, :doc, :xphash
      attr_accessor :split_data, :merged_data, :transformed_data,
        :combined_data, :errors, :warnings, :identifier, :terms,
        :record_status, :csid, :uri, :refname

      def initialize(
        data_hash,
        status_checker = CollectionSpace::Mapper.status_checker
      )
        @orig_data = data_hash
        @status_checker = status_checker
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

      def add_doc(doc)
        @doc = doc
      end

      def add_warning(warning)
        warnings << warning
      end

      def add_xphash(hash)
        @xphash = hash
      end

      def valid?
        @errors.empty?
      end

      def set_record_status
        if CollectionSpace::Mapper.batch.check_record_status
          result = status_checker.call(self)
          @record_status = result[:status]
          @csid = result[:csid]
          @uri = result[:uri]
          @refname = result[:refname]
        else
          @record_status = :new
        end
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

      private

      attr_reader :status_checker
    end
  end
end

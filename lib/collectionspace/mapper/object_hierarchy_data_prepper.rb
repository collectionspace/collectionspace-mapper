# frozen_string_literal: true

require_relative "data_prepper"
require_relative "term_searchable"

module CollectionSpace
  module Mapper
    class ObjectHierarchyDataPrepper < CollectionSpace::Mapper::DataPrepper
      include CollectionSpace::Mapper::TermSearchable
      attr_reader :errors, :warnings, :type, :subtype

      # @param data [Hash, CollectionSpace::Mapper::Response]
      def initialize(data)
        super
        @cache = CollectionSpace::Mapper.termcache
        @type = @response.merged_data["subjectdocumenttype"]
        @subtype = ""
        @errors = []
        @warnings = []
      end

      def prep
        set_id
        split_data
        transform_terms
        combine_data_fields
        push_errors_and_warnings
        self
      end

      private

      def set_id
        bt = @response.merged_data["broader_object_number"]
        nt = @response.merged_data["narrower_object_number"]
        @response.add_identifier("#{bt} > #{nt}")
      end

      def transform_terms
        %w[broader_object_number narrower_object_number].each do |field|
          @response.transformed_data[field] = transformed_term(field)
        end

        @response.split_data.each do |field, value|
          unless @response.transformed_data.key?(field)
            @response.transformed_data[field] =
              value
          end
        end
      end

      def transformed_term(field)
        @response.split_data[field].map { |term| obj_csid(term, @type) }
      end
    end
  end
end

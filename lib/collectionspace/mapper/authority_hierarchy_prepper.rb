# frozen_string_literal: true

require_relative "data_prepper"
require_relative "term_searchable"

module CollectionSpace
  module Mapper
    class AuthorityHierarchyPrepper < CollectionSpace::Mapper::DataPrepper
      include CollectionSpace::Mapper::TermSearchable
      attr_reader :errors, :warnings, :type, :subtype

      # @param data [Hash, CollectionSpace::Mapper::Response]
      # @param searcher [CollectionSpace::Mapper:Searcher]
      # @param handler [CollectionSpace::Mapper::DataHandler]
      def initialize(
        data,
        searcher = CollectionSpace::Mapper.searcher,
        handler = CollectionSpace::Mapper.data_handler
      )
        super
        @cache = CollectionSpace::Mapper.termcache
        @type = @response.merged_data["term_type"]
        @subtype = @response.merged_data["term_subtype"]
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
        bt = @response.merged_data["broader_term"]
        nt = @response.merged_data["narrower_term"]
        @response.identifier = "#{bt} > #{nt}"
      end

      def transform_terms
        %w[broader_term narrower_term].each do |field|
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
        @response.split_data[field].map { |term| term_csid(term) }
      end
    end
  end
end

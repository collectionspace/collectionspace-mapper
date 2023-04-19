# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class AuthorityHierarchyPrepper < CollectionSpace::Mapper::DataPrepper
      include CollectionSpace::Mapper::TermSearchable

      # @param data [Hash, CollectionSpace::Mapper::Response]
      def initialize(data, handler)
        super
        @cache = handler.termcache
        @type = response.merged_data["term_type"]
        @subtype = response.merged_data["term_subtype"]
      end

      def prep
        set_id
        split_data
        transform_terms
        combine_data_fields
        response
      end

      private

      attr_reader :type, :subtype

      def set_id
        bt = response.merged_data["broader_term"]
        nt = response.merged_data["narrower_term"]
        response.add_identifier("#{bt} > #{nt}")
      end

      def transform_terms
        %w[broader_term narrower_term].each do |field|
          response.transformed_data[field] = transformed_term(field)
        end

        response.split_data.each do |field, value|
          unless response.transformed_data.key?(field)
            response.transformed_data[field] =
              value
          end
        end
      end

      def transformed_term(field)
        response.split_data[field].map{ |term| term_csid(term) }
      end
    end
  end
end

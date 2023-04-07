# frozen_string_literal: true

require_relative "data_prepper"
require_relative "term_searchable"

module CollectionSpace
  module Mapper
    class ObjectHierarchyDataPrepper < CollectionSpace::Mapper::DataPrepper
      include CollectionSpace::Mapper::TermSearchable
      attr_reader :errors, :warnings, :type, :subtype

      def initialize(data, searcher, handler)
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
        @response.identifier = "#{bt} > #{nt}"
      end

      def process_xpaths
        clear_unmapped_mappings
        CollectionSpace::Mapper.recordmapper.xpath = @handler.xpath_hash
        super
      end

      # these mappings were needed to get data in via template for processing,
      #   but do not actually get used to produce XML
      def clear_unmapped_mappings
        to_clear = %w[termType termSubType]
        CollectionSpace::Mapper.recordmapper.mappings.reject! { |mapping|
          to_clear.include?(mapping.fieldname)
        }
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

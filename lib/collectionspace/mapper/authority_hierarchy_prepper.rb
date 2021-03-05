# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class AuthorityHierarchyPrepper < CollectionSpace::Mapper::DataPrepper
      include CollectionSpace::Mapper::TermSearchable
      attr_reader :errors, :warnings
      
      def initialize(data, handler)
        super
        @cache = @handler.csidcache
        @type = @response.merged_data['term_type']
        @subtype = @response.merged_data['term_subtype']
        @errors = []
        @warnings = []
      end
      
      def prep
        set_id
        split_data
        transform_terms
        combine_data_fields
        unless errors.empty?
          @response.errors << errors
          @response.errors.flatten!
        end
        unless warnings.empty?
          @response.warnings << warnings
          @response.warnings.flatten!
        end
        @response
      end

      private

      def set_id
        bt = @response.merged_data['broader_term']
        nt = @response.merged_data['narrower_term']
        @response.identifier = "#{bt} > #{nt}"
      end
      
      def process_xpaths
        clear_unmapped_mappings
        @handler.mapper[:xpath] = @handler.xpath_hash
        super
      end
      

      # these mappings were needed to get data in via template for processing, but
      #  do not actually get used to produce XML
      def clear_unmapped_mappings
        to_clear = %w[termType termSubType]
        @handler.mapper[:mappings].reject!{ |m| to_clear.include?(m[:fieldname]) }
      end

      def transform_terms
        %w[broader_term narrower_term].each do |field|
          transformed = @response.split_data[field].map{ |term| term_csid(term) }
          @response.transformed_data[field] = transformed
        end

        @response.split_data.each do |field, value|
          unless @response.transformed_data.key?(field)
            @response.transformed_data[field] = value
          end
        end
      end

      def type
        @type
      end

      def subtype
        @subtype
      end
    end
  end
end
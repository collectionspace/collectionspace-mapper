# frozen_string_literal: true

require 'collectionspace/mapper/data_prepper'
require 'collectionspace/mapper/term_searchable'

module CollectionSpace
  module Mapper
    class NonHierarchicalRelationshipPrepper < CollectionSpace::Mapper::DataPrepper
      include CollectionSpace::Mapper::TermSearchable
      attr_reader :errors, :warnings, :responses

      def initialize(data, handler)
        super
        @cache = @handler.mapper.termcache
        @types = [@response.merged_data['item1_type'], @response.merged_data['item2_type']]
        @errors = []
        @warnings = []
        @responses = []
      end

      def prep
        @response.identifier = "#{stringify_item(1)} -> #{stringify_item(2)}"
        split_data
        transform_terms
        push_errors_and_warnings
        combine_data_fields
        @responses << @response
        flip_response
        self
      end

      private

      def stringify_item(item_number)
        id = "item#{item_number}_id"
        type = "item#{item_number}_type"
        thisid = @response.merged_data[id]
        thistype = @response.merged_data[type]
        "#{thisid} (#{thistype})"
      end

      def flip_response
        resp2 = @response.dup
        resp2.identifier = "#{stringify_item(2)} -> #{stringify_item(1)}"
        resp2.combined_data = {'relations_common' => {}}
        origrel = @response.combined_data['relations_common']['relationshipType']
        origsub = @response.combined_data['relations_common']['subjectCsid']
        origobj = @response.combined_data['relations_common']['objectCsid']
        resp2.combined_data['relations_common']['relationshipType'] = origrel
        resp2.combined_data['relations_common']['subjectCsid'] = origobj
        resp2.combined_data['relations_common']['objectCsid'] = origsub
        @responses << resp2
      end

      def process_xpaths
        clear_unmapped_mappings
        @handler.mapper.xpath = @handler.xpath_hash
        super
      end

      # these mappings were needed to get data in via template for processing, but
      #  do not actually get used to produce XML
      def clear_unmapped_mappings
        to_clear = %w[subjectType objectType]
        @handler.mapper.mappings.reject!{ |mapping| to_clear.include?(mapping.fieldname) }
      end

      def transform_terms
        %w[item1_id item2_id].each_with_index do |field, i|
          transformed = @response.split_data[field].map{ |id| obj_csid(id, @types[i]) }
          @response.transformed_data[field] = transformed
        end

        @response.split_data.each do |field, value|
          unless @response.transformed_data.key?(field)
            @response.transformed_data[field] = value
          end
        end
      end
    end
  end
end

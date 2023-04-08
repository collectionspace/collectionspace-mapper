# frozen_string_literal: true

require "collectionspace/mapper/data_prepper"
require "collectionspace/mapper/term_searchable"

module CollectionSpace
  module Mapper
    class NonHierarchicalRelationshipPrepper <
        CollectionSpace::Mapper::DataPrepper
      include CollectionSpace::Mapper::TermSearchable
      attr_reader :errors, :warnings, :responses, :type, :subtype

      def initialize(
        data,
        searcher = CollectionSpace::Mapper.searcher,
        handler = CollectionSpace::Mapper.data_handler
      )
        super
        @cache = CollectionSpace::Mapper.termcache
        @types = [@response.merged_data["item1_type"],
          @response.merged_data["item2_type"]]
        @subtype = ""
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
        resp2.combined_data = {"relations_common" => {}}
        origrel =
          @response.combined_data["relations_common"]["relationshipType"]
        origsub = @response.combined_data["relations_common"]["subjectCsid"]
        origobj = @response.combined_data["relations_common"]["objectCsid"]
        resp2.combined_data["relations_common"]["relationshipType"] = origrel
        resp2.combined_data["relations_common"]["subjectCsid"] = origobj
        resp2.combined_data["relations_common"]["objectCsid"] = origsub
        @responses << resp2
      end

      def get_rec_csid(id, type)
        instance_variable_set(:@type, type)
        obj_csid(id, type)
      end

      def transform_terms
        %w[item1_id item2_id].each_with_index do |field, i|
          transformed = @response.split_data[field].map { |id|
            get_rec_csid(id, @types[i])
          }
          @response.transformed_data[field] = transformed
        end

        @response.split_data.each do |field, value|
          unless @response.transformed_data.key?(field)
            @response.transformed_data[field] =
              value
          end
        end
      end
    end
  end
end

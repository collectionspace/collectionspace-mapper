# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class NonHierarchicalRelationshipPrepper <
        CollectionSpace::Mapper::DataPrepper
      include CollectionSpace::Mapper::TermSearchable

      def initialize(data, handler)
        super
        @types = [
          response.merged_data["item1_type"],
          response.merged_data["item2_type"]
        ]
        @subtype = ""
        @responses = []
      end

      def prep
        response.add_identifier("#{stringify_item(1)} -> #{stringify_item(2)}")
        split_data
        transform_terms
        combine_data_fields
        responses << response
        flip_response
        responses
      end

      private

      attr_reader :types, :responses, :type, :subtype

      def stringify_item(item_number)
        id = "item#{item_number}_id"
        type = "item#{item_number}_type"
        thisid = response.merged_data[id]
        thistype = response.merged_data[type]
        "#{thisid} (#{thistype})"
      end

      def flip_response
        resp2 = response.dup
        resp2.add_identifier("#{stringify_item(2)} -> #{stringify_item(1)}")
        if response.valid?
          resp2.combined_data = {"relations_common" => {}}
          origrel =
            response.combined_data["relations_common"]["relationshipType"]
          origsub = response.combined_data["relations_common"]["subjectCsid"]
          origobj = response.combined_data["relations_common"]["objectCsid"]
          resp2.combined_data["relations_common"]["relationshipType"] = origrel
          resp2.combined_data["relations_common"]["subjectCsid"] = origobj
          resp2.combined_data["relations_common"]["objectCsid"] = origsub
        end
        responses << resp2
      end

      def get_rec_csid(id, type)
        instance_variable_set(:@type, type)
        obj_csid(id, type)
      end

      def transform_terms
        %w[item1_id item2_id].each_with_index do |field, i|
          transformed = response.split_data[field].map { |id|
            get_rec_csid(id, types[i])
          }
          response.transformed_data[field] = transformed
        end

        response.split_data.each do |field, value|
          unless response.transformed_data.key?(field)
            response.transformed_data[field] =
              value
          end
        end
      end
    end
  end
end

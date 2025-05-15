# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class Searcher
      # @param handler [CollectionSpace::Mapper::DataHandler]
      def initialize(handler)
        handler.config.searcher = self
        @client = handler.client
        @active = handler.batch.search_if_not_cached
        @search_fields = {}
      end

      def call(value:, type:, subtype: nil)
        return nil unless active

        search_response(value, type, subtype)
      end

      private

      attr_reader :client, :active, :search_fields

      def search_response(value, type, subtype)
        as_is = get_response(value, type, subtype)
        return as_is if response_usable?(as_is)

        case_insensitive_response(value, type, subtype)
      end

      def get_response(value, type, subtype, operator = "=")
        response = client.find(
          type: type,
          subtype: subtype,
          value: value,
          field: search_field(type),
          operator: operator
        )
      rescue => e
        puts e.message
        nil
      else
        parse_response(response)
      end

      def response_usable?(response)
        ct = response_item_count(response)
        return false unless ct
        return false if ct == 0

        true
      end

      def case_insensitive_response(value, type, subtype)
        response = get_response(value, type, subtype, "ILIKE")
        return nil unless response_usable?(response)

        displayname = response.dig("list_item", 0, "displayName") ||
          response.dig("list_item", 0, "termDisplayName")
        warning = {
          category: "case_insensitive_match",
          message: "Searched: #{value}. Using: #{displayname}"
        }
        response["warnings"] = [warning]
        response
      end

      def search_field(type)
        cached_field = search_fields[type]
        return cached_field if cached_field

        lookup_search_field(type)
      end

      def lookup_search_field(type)
        field = CollectionSpace::Service.get(type: type)[:term]
      rescue => e
        puts e.message
      else
        @search_fields[type] = field
        field
      end

      def parse_response(response)
        parsed = response.parsed["abstract_common_list"]
        return parsed if parsed["list_item"].is_a?(Array)

        parsed["list_item"] = [parsed["list_item"]]
        parsed
      rescue => e
        puts e.message
        nil
      else
        parsed
      end

      def response_item_count(response) = response.dig("totalItems")&.to_i
    end
  end
end

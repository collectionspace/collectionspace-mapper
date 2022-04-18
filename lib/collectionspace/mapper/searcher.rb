# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class Searcher
      def initialize(client:, config: CS::Mapper::Config.new({}))
        @client = client
        @active = config.search_if_not_cached
        @search_fields = {}
      end

      def call(value:, type:, subtype: nil)
        return nil unless active

        search_response(value, type, subtype)
      end

      private

      attr_reader :client, :active, :search_fields

      def case_swap(string)
        string.match?(/[A-Z]/) ? string.downcase : string.capitalize
      end

      def get_response(value, type, subtype)
        response = client.find(
          type: type,
          subtype: subtype,
          value: value,
          field: search_field(type)
        )
      rescue StandardError => e
        puts e.message
        nil
      else
        parse_response(response)
      end

      def lookup_search_field(type)
        field = CollectionSpace::Service.get(type: type)[:term]
      rescue StandardError => e
        puts e.message
      else
        @search_fields[type] = field
        field
      end

      def parse_response(response)
        parsed = response.parsed['abstract_common_list']
      rescue StandardError => e
        puts e.message
        nil
      else
        parsed
      end

      def response_item_count(response)
        ct = response.dig('totalItems')
        return ct.to_i if ct

        nil
      end
      
      def response_usable?(response)
        ct = response_item_count(response)
        return false unless ct
        return false if ct == 0

        true
      end

      def search_field(type)
        cached_field = search_fields[type]
        return cached_field if cached_field

        lookup_search_field(type)
      end
      
      def search_response(value, type, subtype)
        as_is = get_response(value, type, subtype)
        return as_is if response_usable?(as_is)

        get_response(case_swap(value), type, subtype)
      end
    end
  end
end

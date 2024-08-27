# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class AuthorityPrepper < CollectionSpace::Mapper::DataPrepper
      def prep
        super
        add_short_id_to_transformed_data
        combine_data_fields
        response
      end

      private

      attr_reader :type, :subtype

      def get_id
        if response.transformed_data.key?("shortidentifier")
          response.transformed_data["shortidentifier"][0]
        else
          term = response.split_data["termdisplayname"][0]
          CollectionSpace::Mapper::Identifiers::AuthorityShortIdentifier.call(
            term
          )
        end
      end

      def add_short_id_to_transformed_data
        return if response.transformed_data.key?("shortidentifier")

        response.transformed_data["shortidentifier"] = [response.identifier]
      end
    end
  end
end

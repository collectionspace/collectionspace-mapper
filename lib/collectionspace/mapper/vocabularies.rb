# frozen_string_literal: true

require 'dry/monads'

module CollectionSpace
  module Mapper
    # Various types of access to the vocabularies defined in a CS instance
    class Vocabularies
      include Dry::Monads[:result]

      def initialize(client)
        @vocabs = populate_vocabs(client)
      end

      # @param name [String] display or machine name of vocabulary
      def by_name(name)
        result = vocabs.select{ |vocab| vocab['displayName'] == name }

        if result.empty?
          result = vocabs.select do |vocab|
            vocab['shortIdentifier'].downcase == name.downcase
          end
        end

        if result.empty?
          Failure("Vocabulary `#{name}` does not exist")
        else
          Success(result.first)
        end
      end

      private

      attr_reader :vocabs

      def populate_vocabs(client)
        all = []
        client.all('vocabularies').each{ |v| all << v }
        all
      end
    end
  end
end

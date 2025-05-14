# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"

module CollectionSpace
  module Mapper
    module VocabularyTerms
      # Sets up a class with client context, that can process terms from
      #   multiple vocabularies
      class Handler
        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:add_term)

        def initialize(client:)
          @client = client
          @domain = client.domain
          @vocabs = CollectionSpace::Mapper::Vocabularies.new(client)
        end

        # @param vocab [String] the display name of the target Vocabulary
        # @param term [String] the term to create in the Vocabulary
        def add_term(vocab:, term:, opt_fields: nil)
          vocabulary = yield vocabs.by_name(vocab)
          tid = yield get_termid(term)
          vname = vocabulary["shortIdentifier"]

          params = {
            domain: domain,
            csid: vocabulary["csid"],
            name: vname,
            term: term,
            termid: tid
          }
          params[:opt_fields] = opt_fields if opt_fields

          payload = yield PayloadBuilder.call(**params)
          path = "#{vocabulary["uri"]}/items"
          posting = yield post_term(path, payload, vname, term)

          Success(posting.sub(/^.*cspace-services/, ""))
        end

        private

        attr_reader :client, :domain, :vocabs

        def get_termid(term)
          result = CollectionSpace::Mapper::Identifiers::ShortIdentifier.call(
            term
          )
        rescue => err
          Failure(err)
        else
          Success(result)
        end

        def post_term(path, payload, vname, term)
          result = client.post(path, payload)
        rescue => err
          Failure(err)
        else
          case result.status_code
          when 409
            Failure("#{vname}/#{term} already exists")
          when 201
            Success(result.result.headers["location"])
          else
            Failure(result)
          end
        end
      end
    end
  end
end

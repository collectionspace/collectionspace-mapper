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
        include Dry::Monads::Do.for(:add_term, :added_term_params,
                                    :term_payload)

        def initialize(client:)
          @client = client
          @domain = client.domain
          @vocabs = CollectionSpace::Mapper::Vocabularies.new(client)
        end


        # @param vocab [String] the display name of the target Vocabulary
        # @param term [String] the term to create in the Vocabulary
        # @param mode [:add, :update]
        # @param opt_fields [nil, Hash{String => String}] key/value pairs for
        #   description, source, sourcePage, and termStatus fields
        def term_payload(vocab:, term:, mode: :add, opt_fields: nil)
          params = case mode
                   when :add
                     yield added_term_params(
                       vocab: vocab, term: term, opt_fields: opt_fields
                     )
                   end
          payload = yield PayloadBuilder.call(**params)

          Success(payload)
        end

        # @param vocab [String] the display name of the target Vocabulary
        # @param term [String] the term to create in the Vocabulary
        # @param opt_fields [nil, Hash{String => String}] key/value pairs for
        #   description, source, sourcePage, and termStatus fields
        def add_term(vocab:, term:, opt_fields: nil)
          vocabulary = yield vocabs.by_name(vocab)
          payload = yield term_payload(
            vocab: vocab, term: term, mode: :add, opt_fields: opt_fields
          )
          path = "#{vocabulary["uri"]}/items"
          posting = yield post_term(
            path, payload, vocabulary["shortIdentifier"], term)

          Success(posting.sub(/^.*cspace-services/, ""))
        end

        private

        attr_reader :client, :domain, :vocabs

        # @param vocab [String] the display name of the target Vocabulary
        # @param term [String] the term to create in the Vocabulary
        # @param opt_fields [nil, Hash{String => String}] key/value pairs for
        #   description, source, sourcePage, and termStatus fields
        def added_term_params(vocab:, term:, opt_fields: nil)
          vocabulary = yield vocabs.by_name(vocab)
          tid = yield get_termid(term)

          params = {
            domain: domain,
            csid: vocabulary["csid"],
            name: vocabulary["shortIdentifier"],
            term: term,
            termid: tid
          }
          params[:opt_fields] = opt_fields if opt_fields

          Success(params)
        end

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

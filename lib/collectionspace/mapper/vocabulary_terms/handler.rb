# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"

module CollectionSpace
  module Mapper
    module VocabularyTerms
      # Sets up a class with client context, that can process terms from
      #   multiple vocabularies
      class Handler
        include Dry::Configurable
        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:add_term, :update_term, :added_term_params,
          :term_payload)

        attr_reader :client

        # @return [CollectionSpace::Mapper::Searcher, nil] class used to look up
        #   terms in CS instance for the batch run
        setting :searcher, default: nil, reader: true

        setting :batch, reader: true do
          setting :search_if_not_cached, default: true, reader: true
        end

        def initialize(client:)
          @client = client
          @domain = client.domain
          @vocabs = CollectionSpace::Mapper::Vocabularies.new(client)
          CollectionSpace::Mapper::Searcher.new(self)
        end

        # @param vocab [String] the display name of the target Vocabulary
        # @param term [String, Hash] if mode is :add, the term string to create;
        #   if mode is :update, existing record for term, returned by searcher
        # @param mode [:add, :update]
        # @param opt_fields [nil, Hash{String => String}] key/value pairs for
        #   description, source, sourcePage, and termStatus fields
        def term_payload(vocab:, term:, mode: :add, opt_fields: nil)
          params = case mode
          when :add
            yield added_term_params(
              vocab: vocab, term: term, opt_fields: opt_fields
            )
          when :update
            yield updated_term_params(
              vocab: vocab, term_data: term, opt_fields: opt_fields
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
            vocab: vocabulary, term: term, mode: :add, opt_fields: opt_fields
          )
          path = "#{vocabulary["uri"]}/items"
          posting = yield post_term(
            path, payload, vocabulary["shortIdentifier"], term
          )

          Success(posting.sub(/^.*cspace-services/, ""))
        end

        # @param vocab [String] the display name of the target Vocabulary
        # @param term [String] the term to create in the Vocabulary
        # @param opt_fields [nil, Hash{String => String}] key/value pairs for
        #   description, source, sourcePage, and termStatus fields
        def update_term(vocab:, term:, opt_fields: nil)
          vocabulary = yield vocabs.by_name(vocab)
          termresp = searcher.call(
            value: term, type: "vocabularies",
            subtype: vocabulary["shortIdentifier"]
          )
          unless termresp
            return Failure("The term \"#{term}\" does not exist in #{vocab}")
          end

          termrec = termresp.dig("list_item", 0)
          payload = yield term_payload(
            vocab: vocabulary, term: termrec, mode: :update,
            opt_fields: opt_fields
          )
          path = termrec["uri"]
          putting = yield put_term(path, payload)

          Success(putting)
        end

        private

        attr_reader :domain, :vocabs

        # @param vocab [String] the display name of the target Vocabulary
        # @param term [String] the term to create in the Vocabulary
        # @param opt_fields [nil, Hash{String => String}] key/value pairs for
        #   description, source, sourcePage, and termStatus fields
        def added_term_params(vocab:, term:, opt_fields: nil)
          tid = yield get_termid(term)

          params = {
            domain: domain,
            csid: vocab["csid"],
            name: vocab["shortIdentifier"],
            term: term,
            term_data: {"shortIdentifier" => tid}
          }
          params[:opt_fields] = opt_fields if opt_fields

          Success(params)
        end

        # @param vocab [String] the display name of the target Vocabulary
        # @param term_data [Hash] existing record for the term
        # @param opt_fields [nil, Hash{String => String}] key/value pairs for
        #   description, source, sourcePage, and termStatus fields
        def updated_term_params(vocab:, term_data:, opt_fields: nil)
          params = {
            domain: domain,
            csid: vocab["csid"],
            name: vocab["shortIdentifier"],
            term: term_data["displayName"],
            term_data: {"shortIdentifier" => term_data["shortIdentifier"]}
          }
          return Success(params) unless opt_fields

          new_term = opt_fields.fetch("displayName", nil)
          unless new_term
            params[:opt_fields] = opt_fields
            return Success(params)
          end

          params[:term] = opt_fields.delete("displayName")
          params[:opt_fields] = opt_fields
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

        def put_term(path, payload)
          result = client.put(path, payload)
        rescue => err
          Failure(err)
        else
          case result.status_code
          when 200
            Success(result.result.dig(
              "document", "collectionspace_core", "uri"
            ))
          else
            Failure(result)
          end
        end
      end
    end
  end
end

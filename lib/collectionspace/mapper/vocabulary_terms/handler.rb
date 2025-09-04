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
        include Dry::Monads[:result, :do]

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
          send_opt_fields = opt_fields || {}
          params = case mode
          when :add
            yield added_term_params(
              vocab: vocab, term: term, opt_fields: send_opt_fields
            )
          when :update
            yield updated_term_params(
              vocab: vocab, term_data: term, opt_fields: send_opt_fields
            )
          end
          params[:mode] = mode
          payload = yield PayloadBuilder.call(**params)

          Success(payload)
        end

        # @param vocab [String] the display name of the target Vocabulary
        # @param term [String] the term to create in the Vocabulary
        # @param opt_fields [nil, Hash{String => String}] key/value pairs for
        #   description, source, sourcePage, and termStatus fields
        def add_term(vocab:, term:, opt_fields: nil)
          vocabulary = yield vocabs.by_name(vocab)
          status = term_status(term, vocabulary)
          vocabshortid = vocabulary["shortIdentifier"]

          if status.first == :exists
            return Failure("#{vocabshortid}/#{term} already exists")
          end

          if status.first == :soft_deleted
            return update_term(vocab: vocab, term: term, opt_fields: opt_fields)
          end

          payload = yield term_payload(
            vocab: vocabulary, term: term, mode: :add, opt_fields: opt_fields
          )
          path = "#{vocabulary["uri"]}/items"
          posting = yield post_term(
            path, payload, vocabshortid, term
          )

          Success(posting.sub(/^.*cspace-services/, ""))
        end

        # @param vocab [String] the display name of the target Vocabulary
        # @param term [String] the term to create in the Vocabulary
        # @param opt_fields [nil, Hash{String => String}] key/value pairs for
        #   description, source, sourcePage, and termStatus fields
        def update_term(vocab:, term:, opt_fields: nil)
          vocabulary = yield vocabs.by_name(vocab)
          status = term_status(term, vocabulary)
          if status.first == :nonexistent
            return Failure("The term \"#{term}\" does not exist in #{vocab}")
          end

          termrec = status[1]
          path = termrec["uri"]
          if status.first == :soft_deleted
            _undelete = yield un_soft_delete(path)
          end

          payload = yield term_payload(
            vocab: vocabulary, term: termrec, mode: :update,
            opt_fields: opt_fields
          )
          putting = yield put_term(path, payload)

          Success(putting)
        end

        # @param vocab [String] the display name of the target Vocabulary
        # @param term [String] the term to create in the Vocabulary
        # @param mode [:soft, :hard] :soft changes workflow state of term to
        #   deleted; :hard actually deletes the term
        def delete_term(vocab:, term:, mode: :soft)
          vocabulary = yield vocabs.by_name(vocab)
          status = term_status(term, vocabulary)
          if status.first == :nonexistent
            return Failure("The term \"#{term}\" does not exist in #{vocab}")
          end

          termrec = status[1]
          path = termrec["uri"]
          if status.first == :soft_deleted
            return Success(path)
          end

          uses = yield term_usage_count(path)
          if uses > 0
            return Failure("#{vocab}/#{term} is used in records #{uses} times")
          end

          deleting = case mode
          when :hard
            yield delete(path)
          when :soft
            yield soft_delete(path)
          end

          Success(deleting)
        end

        private

        attr_reader :domain, :vocabs

        def term_status(term, vocab)
          response = searcher.call(
            value: term, type: "vocabularies", subtype: vocab["shortIdentifier"]
          )
          return [:nonexistent, nil] unless response

          grouped = response.dig("list_item")
            .group_by { |item| item["workflowState"] }
          if grouped.key?("project")
            [:exists, grouped["project"].first]
          elsif grouped.key?("deleted")
            [:soft_deleted, grouped["deleted"].first]
          else
            [:unknown, grouped]
          end
        end

        def term_usage_count(path)
          use_path = "#{path}/refObjs"
          result = client.get(use_path)
        rescue => err
          Failure(err)
        else
          case result.status_code
          when 200
            ct = result.parsed
              &.fetch("authority_ref_doc_list")
              &.fetch("totalItems")
              &.to_i
            if ct.is_a?(Integer)
              Success(ct)
            else
              Failure("Usage count cannot be extracted from #{result.parsed}")
            end
          else
            Failure(result)
          end
        end

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

        def delete(path)
          result = client.delete(path)
        rescue => err
          Failure(err)
        else
          case result.status_code
          when 200
            Success("#{path} deleted")
          else
            Failure(result)
          end
        end

        def soft_delete(path)
          result = client.send(:request, "PUT", "#{path}/workflow/delete")
        rescue => err
          Failure(err)
        else
          case result.status_code
          when 200
            Success(path)
          else
            Failure(result)
          end
        end

        def un_soft_delete(path)
          result = client.send(:request, "PUT", "#{path}/workflow/undelete")
        rescue => err
          Failure(err)
        else
          case result.status_code
          when 200
            Success(path)
          else
            Failure(result)
          end
        end
      end
    end
  end
end

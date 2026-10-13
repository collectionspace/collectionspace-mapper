# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"

module CollectionSpace
  module Mapper
    module VocabularyTerms
      # Sets up a class with client context, that can process terms from
      #   multiple vocabularies.
      #
      # @note In order to properly handle soft deleted vocabulary terms, the
      #   client should have its `#config.include_deleted` set to true before
      #   passing it to construct this class.
      class Handler
        # @return [Array<String>] allowable optional fields for vocabulary terms
        OPT_FIELDS = %w[description source sourcepage termstatus]

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

        # @param term [String, Hash] if mode is :add, the term string to create;
        #   if mode is :update, existing record for term, returned by searcher
        # @param mode [:add, :update]
        # @param vocab [nil, String] the display or machine name of the target
        #   Vocabulary; not required for :update mode
        # @param opt_fields [nil, Hash{String => String}] key/value pairs for
        #   description, source, sourcePage, and termStatus fields
        def term_payload(term:, mode: :add, vocab: nil, opt_fields: nil)
          send_opt_fields = opt_fields || {}
          params = case mode
          when :add
            yield added_term_params(
              vocab: vocab, term: term, opt_fields: send_opt_fields
            )
          when :update
            yield updated_term_params(
              term_data: term, opt_fields: send_opt_fields
            )
          end
          params[:mode] = mode
          payload = yield PayloadBuilder.call(**params)

          Success(payload)
        end

        # @param vocab [String] the display or machine name of the target
        #   Vocabulary
        # @param term [String] the term to create in the Vocabulary
        # @param opt_fields [nil, Hash{String => String}] key/value pairs for
        #   description, source, sourcePage, and termStatus fields
        # @param row [CSV::Row] used to optionally extract opt_fields, if that
        #   param is not explicitly given
        def add_term(vocab:, term:, opt_fields: nil, row: nil)
          vocabulary = yield vocabs.by_name(vocab)
          status = term_status(term, vocabulary)
          vocabshortid = vocabulary["shortIdentifier"]

          opt_fields = extract_opt_fields(row) if !opt_fields && row

          if status.first == :exists || status.first == :soft_deleted
            return update_known_term(
              term: term,
              opt_fields: opt_fields,
              status: status.first,
              current_term: status.last
            )
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
        # @param row [CSV::Row] used to optionally extract opt_fields, if that
        #   param is not explicitly given
        def update_term(vocab:, term:, opt_fields: nil, row: nil)
          vocabulary = yield vocabs.by_name(vocab)
          status = term_status(term, vocabulary)

          opt_fields = extract_opt_fields(row) if !opt_fields && row

          if status.first == :nonexistent
            return Failure("The term \"#{term}\" does not exist in "\
                           "#{vocab}")
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
        # @param term [String] the term to delete from the Vocabulary
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

        def extract_opt_fields(row)
          return unless OPT_FIELDS.any? { |f| row.key?(f) }

          result = OPT_FIELDS.to_h { |f| [f, row[f]] }
            .compact
          return if result.empty?

          result
        end

        # @param term [String] the term to update in the Vocabulary
        # @param status [Symbol]
        # @param current_term [Hash] from previous API search to get status
        # @param opt_fields [nil, Hash{String => String}] key/value pairs for
        #   description, source, sourcePage, and termStatus fields
        def update_known_term(term:, status:, current_term:, opt_fields: nil)
          opt_fields ||= {}
          path = current_term["uri"]

          if status == :soft_deleted
            _undelete = yield un_soft_delete(path)
          end

          if current_term["displayName"] == term && opt_fields.empty?
            return Success(current_term)
          end

          unless current_term["displayName"] == term
            opt_fields.merge({"displayName" => term})
            current_term["displayName"] = term
          end

          payload = yield term_payload(
            term: current_term, mode: :update, opt_fields: opt_fields
          )

          putting = yield put_term(path, payload)

          Success(putting)
        end

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

        # @param term_data [Hash] existing record for the term
        # @param opt_fields [nil, Hash{String => String}] key/value pairs for
        #   description, source, sourcePage, and termStatus fields
        # @return [Hash]
        def updated_term_params(term_data:, opt_fields: nil)
          params = {
            domain: domain,
            csid: term_data["csid"],
            name: term_data["shortIdentifier"],
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

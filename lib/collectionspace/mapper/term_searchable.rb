# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module TermSearchable
      include Cacheable
      include CaseSwappable
      include TypeSubtypeable

      private

      def client
        handler.client
      end

      def searcher
        handler.searcher
      end

      # returns specified data type (:csid or :refname) for searched term
      # @param val [String] termDisplayName value to search for
      # @param return_type [Symbol<:csid, :refname>]
      def searched_term(
        val,
        return_type,
        termtype = type,
        termsubtype = subtype
      )
        apiresponse = searcher.call(
          value: val,
          type: termtype,
          subtype: termsubtype
        )
        return nil unless apiresponse

        rec = rec_from_response("term", val, apiresponse)
        return nil unless rec

        values = {refname: rec["refName"], csid: rec["csid"]}
        cache_term_values([termtype, termsubtype, val], values)
        values[return_type]
      end

      # @param objnum [String] identifier field value of object or procedure
      # @param type [String] record type name
      # @return [String] csid of given object or procedure
      def obj_csid(objnum, type)
        cached = cached_obj_or_procedure_csid(objnum, type)
        return cached if cached

        lookup_obj_or_procedure_csid(objnum, type)
      end

      def lookup_obj_or_procedure_csid(objnum, type)
        category = "object_or_procedure"
        apiresponse = searcher.call(type: type, value: objnum)

        if apiresponse
          result_ct = apiresponse["totalItems"]
          case result_ct
          when "1"
            rec = rec_from_response(category, objnum, apiresponse)
            return nil unless rec

            csid = rec["csid"]
            cache_obj_or_procedure_csid(objnum, type, csid)
            cache_obj_or_procedure_refname(objnum, type, rec["refName"])
            csid
          when "0"
            response.add_error({
              category: :"unsuccessful_csid_lookup_for_#{category}",
              field: "",
              subtype: "",
              type: type,
              value: objnum,
              message: "No record (and no CSID) found for #{objnum}."
            })
            nil
          else
            response.add_error({
              category: :"multiple_records_found_for_#{category}",
              field: column,
              type: type,
              subtype: subtype,
              value: val,
              message: "#{result_ct} records found with record id: #{val}"
            })
          end
        else
          response.add_error({
            category: :"unsuccessful_csid_lookup_for_#{category}",
            field: "",
            subtype: "",
            type: type,
            value: objnum,
            message: "Problem with search for #{objnum}."
          })
          nil
        end
      end

      def term_csid(term)
        cached = cached_term_csid(term)
        return cached if cached

        found = searched_term(term, :csid)
        return found if found

        response.add_error({
          category: :unsuccessful_csid_lookup_for_term,
          field: "",
          type: type,
          subtype: subtype,
          value: term,
          message: "Problem with search for #{term}."
        })
      end

      def response_item_count(apiresponse)
        ct = apiresponse.dig("totalItems")
        return ct.to_i if ct

        nil
      end

      def add_missing_record_error(category, val)
        response.add_error({
          category: :"no_records_found_for_#{category}",
          field: column,
          type: type,
          subtype: subtype,
          value: val,
          message: "#{val} (#{type_subtype} in #{column} column)"
        })
      end

      def rec_from_response(category, val, apiresponse)
        term_ct = response_item_count(apiresponse)

        if term_ct
          return_record(category, val, apiresponse, term_ct)
        else
          add_bad_lookup_error(category, val)
        end
      end

      def return_record(category, val, apiresponse, term_ct)
        rec = apiresponse["list_item"][0]

        case term_ct
        when 0
          nil
        when 1
          if apiresponse.key?("warnings")
            apiresponse["warnings"].each do |warning|
              response.add_warning(warning.merge({field: column}))
            end
          end
          rec
          # rec = apiresponse["list_item"]
        else
          using_uri = "#{client.config.base_uri}#{rec["uri"]}"
          response.add_warning({
            category: :"multiple_records_found_for_#{category}",
            field: column,
            type: type,
            subtype: subtype,
            value: val,
            message: "#{term_ct} records found. Using #{using_uri}"
          })
          rec
        end
      end

      def add_bad_lookup_error(category, val)
        response.add_error({
          category: :"unsuccessful_csid_lookup_for_#{category}",
          field: column,
          type: type,
          subtype: subtype,
          value: val,
          message: "Problem with search for #{val}"
        })

        nil
      end

      # # added toward refactoring that isn't done yet
      # def get_vocabulary_term(vocab:, term:)
      #   result = termcache.get("vocabularies", vocab, term, search: true)
      #   return result unless result.nil?

      #   if has_caps?(term)
      #     termcache.get("vocabularies", vocab, term.downcase, search: true)
      #   else
      #     termcache.get("vocabularies", vocab, term.capitalize, search: true)
      #   end
      # end
    end
  end
end

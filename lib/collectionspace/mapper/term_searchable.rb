# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module TermSearchable
      def in_cache?(val)
        return true if @cache.exists?(type, subtype, val)
        return true if @cache.exists?(type, subtype, case_swap(val))

        false
      end

      # returns whether value is cached as an unknownvalue
      def cached_as_unknown?(val)
        return true if @cache.exists?('unknownvalue', type_subtype, val)
        return true if @cache.exists?('unknownvalue', type_subtype, case_swap(val))

        false
      end

      def cached_unknown(type_subtype, val)
        @cache.get('unknownvalue', type_subtype, val)
      end

      private def type_subtype
        "#{type}/#{subtype}"
      end

      # returns refName of cached term
      def cached_term(val, termtype = type, termsubtype = subtype)
        returned = @cache.get(termtype, termsubtype, val)
        return returned if returned

        returned = @cache.get(termtype, termsubtype, case_swap(val))
        return returned if returned
      end

      # returns csid of cached term
      def cached_term_csid(val, termtype = type, termsubtype = subtype)
        returned = @csid_cache.get(termtype, termsubtype, val)
        return returned if returned

        returned = @csid_cache.get(termtype, termsubtype, case_swap(val))
        return returned if returned
      end

      # returns specified data type (:csid or :refname) for searched term
      # @param val [String] termDisplayName value to search for
      # @param return_type [Symbol<:csid, :refname>] 
      def searched_term(val, return_type, termtype = type, termsubtype = subtype)
        response = searcher.call(
          value: val,
          type: termtype,
          subtype: termsubtype
        )
        return nil unless response

        rec = rec_from_response('term', val, response)
        return nil unless rec

        values = {refname: rec['refName'], csid: rec['csid']}
        @cache.put(termtype, termsubtype, val, values[:refname])
        @csid_cache.put(termtype, termsubtype, val, values[:csid])
        values[return_type]
      end

      private def case_swap(string)
        string.match?(/[A-Z]/) ? string.downcase : string.capitalize
      end

      def obj_csid(objnum, type)
        cached = @csid_cache.get(type, '', objnum)
        return cached if cached

        lookup_obj_or_procedure_csid(objnum, type)
      end

      def lookup_obj_or_procedure_csid(objnum, type)
        category = 'object_or_procedure'
        response = searcher.call(type: type, value: objnum)

        if response
          rec = rec_from_response(category, objnum, response)
          return nil unless rec

          csid = rec['csid']
          @csid_cache.put(type, '', objnum, csid)
          @cache.put(type, '', objnum, rec['refName'])
          csid
        else
          errors << {
            category: "unsuccessful_csid_lookup_for_#{category}".to_sym,
            field: '',
            subtype: '',
            type: type,
            value: objnum,
            message: "Problem with search for #{objnum}."
          }
          nil
        end
      end

      def term_csid(term)
        cached = cached_term_csid(term)
        return cached if cached

        searched_term(term, :csid)
      end

      private def response_item_count(response)
        ct = response.dig('totalItems')
        return ct.to_i if ct

        nil
      end

      private def add_missing_record_error(category, val)
        errors << {
          category: "no_records_found_for_#{category}".to_sym,
          field: @column,
          type: type,
          subtype: subtype,
          value: val,
          message: "#{val} (#{type_subtype} in #{@column} column)"
        }
      end

      private def rec_from_response(category, val, response)
        term_ct = response_item_count(response)

        unless term_ct
          errors << {
            category: "unsuccessful_csid_lookup_for_#{category}".to_sym,
            field: @column,
            type: type,
            subtype: subtype,
            value: val,
            message: "Problem with search for #{val}"
          }
          return nil
        end

        case term_ct
        when 0
          add_missing_record_error(category, val)
          rec = nil
        when 1
          rec = response['list_item']
        else
          rec = response['list_item'][0]
          using_uri = "#{@client.config.base_uri}#{rec['uri']}"
          warnings << {
            category: "multiple_records_found_for_#{category}".to_sym,
            field: @column,
            type: type,
            subtype: subtype,
            value: val,
            message: "#{term_ct} records found. Using #{using_uri}"
          }
        end

        rec
      end

      # added toward refactoring that isn't done yet
      def get_vocabulary_term(vocab:, term:)
        result = @cache.get('vocabularies', vocab, term, search: true)
        return result unless result.nil?

        if has_caps?(term)
          @cache.get('vocabularies', vocab, term.downcase, search: true)
        else
          @cache.get('vocabularies', vocab, term.capitalize, search: true)
        end
      end
    end
  end
end

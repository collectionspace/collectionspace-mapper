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

      private def type_subtype
                @type_subtype ||= "#{type}/#{subtype}"
              end

      # returns refName of cached term
      def cached_term(val, return_key = :refname, termtype = type, termsubtype = subtype)
        returned = @cache.get(termtype, termsubtype, val, search: false)
        return convert_cached_value(returned)[return_key] if returned

        returned = @cache.get(termtype, termsubtype, case_swap(val), search: false)
        return convert_cached_value(returned)[return_key] if returned
      end

      private def convert_cached_value(cache_response)
                return cache_response if cache_response.is_a?(Hash)

                instance_eval(cache_response)
              end
      
      # returns refName of searched (term)
      def searched_term(val, return_key = :refname)
        response = term_search_response(val)

        rec = rec_from_response('term', val, response)
        return nil unless rec

        cache_value = { refname: rec['refName'], csid: rec['csid'] }
        @cache.put(type, subtype, val, cache_value)
        cache_value[return_key]
      end

      private def case_swap(string)
                string.match?(/[A-Z]/) ? string.downcase : string.capitalize
              end
      

      private def term_search_response(val)
                as_is = get_term_response(val)
                return as_is if term_response_usable?(as_is)

                get_term_response(case_swap(val))
              end
      
      private def get_term_response(val)
                response = @client.find(
                  type: type,
                  subtype: subtype,
                  value: val,
                  field: search_field
                )
              rescue StandardError => e
                puts e.message
                nil
              else
                parse_response(response)
              end

      private def parse_response(response)
                parsed = response.parsed['abstract_common_list']
              rescue StandardError => e
                puts e.message
                nil
              else
                parsed
              end
      
      def obj_csid(objnum, type)
        cached = @cache.get(type, '', objnum, search: false)
        return convert_cached_value(cached)[:csid] if cached
        
        lookup_obj_csid(objnum, type)
      end

      def lookup_obj_csid(objnum, type)
        response = @client.find(type: type, value: objnum)
        if response.result.success?
          rec = rec_from_response('objnum', objnum, parse_response(response))
          return nil unless rec

          csid = rec['csid']
          @cache.put(type, '', objnum, { refname: rec['refName'], csid: csid } )
          csid
        else
          errors << {
            category: :unsuccessful_csid_lookup_for_objnum,
            field: '',
            subtype: '',
            type: type,
            value: objnum,
            message: "Problem with search for #{objnum}."
          }
          return nil
        end
      end

      def term_csid(term)
        cached = cached_term(term, :csid)
        return cached if cached

        searched_term(term, :csid)
      end

      private def term_response_usable?(response)
                ct = response_item_count(response)
                return false unless ct
                return false if ct == 0

                true
              end
      
      private def response_item_count(response)
                ct = response.dig('totalItems')
                return ct.to_i if ct

                nil
              end

      private def add_missing_record_error(category, val)
                datacolumn = column ||= 'data'
                
                errors << {
                  category: "no_records_found_for_#{category}".to_sym,
                  field: '',
                  type: '',
                  subtype: '',
                  value: val,
                  message: "#{val} (#{type_subtype} in #{datacolumn} column)"
                }
              end
      
      private def rec_from_response(category, val, response)
                term_ct = response_item_count(response)

                unless term_ct
                  errors << {
                    category: "unsuccessful_csid_lookup_for_#{category}".to_sym,
                    field: '',
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
                    field: '',
                    type: type,
                    subtype: subtype,
                    value: val,
                    message: "#{term_ct} records found. Using #{using_uri}"
                  }
                end

                rec
              end
      
      private def search_field
          field = CollectionSpace::Service.get(type: type)[:term]
        rescue StandardError => e
          puts e.message
        else
          field
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

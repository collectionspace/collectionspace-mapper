# frozen_string_literal: true

require 'collectionspace/mapper/tools/refname'

module CollectionSpace
  module Mapper
    class TermHandler
      include TermSearchable

      attr_reader :result, :terms, :warnings, :errors,
                  :column, :source_type, :type, :subtype
      attr_accessor :value
      def initialize(mapping:, data:, client:, cache:, mapper:)
        @mapping = mapping
        @data = data
        @client = client
        @cache = cache
        @mapper = mapper

        @column = mapping.datacolumn
        @field = mapping.fieldname
        @config = @mapper.batchconfig
        @source_type = @mapping.source_type.to_sym
        @terms = []
        case @source_type
        when :authority
          authconfig = @mapping.transforms[:authority]
          @type = authconfig[0]
          @subtype = authconfig[1]
        when :vocabulary
          @type = 'vocabularies'
          @subtype = @mapping.transforms[:vocabulary]
        end
        @warnings = []
        @errors = []
        handle_terms
      end

      private

      def handle_terms
        if @data.first.is_a?(String)
          @result = @data.map{ |val| handle_term(val) }
        else
          @result = @data.map{ |arr| arr.map{ |val| handle_term(val)} }
        end
      end

      def handle_term(val)
        @value = val
        return '' if val.blank? || val == '%NULLVALUE%'
        return THE_BOMB if val == THE_BOMB

        added = false

        term_report = {
          category: source_type,
          field: column
        }

        if in_cache?(val)
          refname_urn = cached_term(val, :refname)
          if refname_urn
            add_found_term(refname_urn, term_report)
            added = true
          end
        else # not in cache
          if @config.check_terms
            refname_urn = searched_term(val, :refname)
            if refname_urn
              add_found_term(refname_urn, term_report)
              added = true
            end
          end
        end

        return refname_urn if added
        
        # this section needs to be updated when not-found terms become blocking errors instead
        #  of warnings. At that point, we no longer want to generate and store a refname for the
        #  term, since it will not be mapped. 
        if cached_as_unknown?(val)
          refname_urn = add_known_unknown_term(val, term_report)
        else
          refname_urn = add_new_unknown_term(val, term_report)
        end
        
        refname_urn
      end

      def add_new_unknown_term(val, term_report)
        refname_obj = CollectionSpace::Mapper::Tools::RefName.new(
          source_type: source_type,
          type: type,
          subtype: subtype,
          term: val,
          cache: @cache)

        @terms << term_report.merge({found: false, refname: refname_obj})
        refname_url = refname_obj.urn
        @cache.put('unknownvalue', unknown_type, val, {refname: refname_url, csid: nil})
        refname_url
      end

      def add_known_unknown_term(val, term_report)
        refname_url = @cache.get('unknownvalue', unknown_type, val)[:refname]
        refname_obj = CollectionSpace::Mapper::Tools::RefName.new(urn: refname_url)
        @terms << term_report.merge({found: false, refname: refname_obj})
        refname_url
      end

      def add_found_term(refname_urn, term_report)
        refname_obj = CollectionSpace::Mapper::Tools::RefName.new(urn: refname_urn)
        found = @config.check_terms ? true : false
        @terms << term_report.merge({found: found, refname: refname_obj})
      end
    end
  end
end


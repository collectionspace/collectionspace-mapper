# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class TermHandler
      include TermSearchable

      attr_reader :result, :terms, :warnings, :errors,
                  :column, :source_type, :type, :subtype
      attr_accessor :value

      def initialize(mapping:, data:, client:, mapper:)
        @mapping = mapping
        @data = data
        @client = client
        @mapper = mapper
        @cache = mapper.termcache
        @csid_cache = mapper.csidcache

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
        @result = if @data.first.is_a?(String)
                    @data.map{ |val| handle_term(val) }
                  else
                    @data.map{ |arr| arr.map{ |val| handle_term(val) } }
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
          refname_urn = cached_term(val)
          if refname_urn
            add_found_term(refname_urn, term_report)
            added = true
          end
        elsif cached_as_unknown?(val)
          refname_urn = add_known_unknown_term(val, term_report)
          added = true
        else # not in cache
          refname_urn = searched_term(val, :refname)
          if refname_urn
            add_found_term(refname_urn, term_report)
            added = true
          end
        end

        return refname_urn if added

        add_new_unknown_term(val, term_report)
      end

      def add_found_term(refname_urn, term_report)
        refname_obj = CollectionSpace::Mapper::Tools::RefName.new(urn: refname_urn)
        found = true
        @terms << term_report.merge({found: found, refname: refname_obj})
      end

      # the next two methods need to be updated when not-found terms become blocking errors instead
      #  of warnings. At that point, we no longer want to generate and store a refname for the
      #  term, since it will not be mapped.
      # at the point of switching error, the termtype and termsubtype parameters can be removed from
      #  cached_term
      def add_new_unknown_term(val, term_report)
        unknown_term = CollectionSpace::Mapper::UnknownTerm.new(
          type: type,
          subtype: subtype,
          term: val
        )
        urn = unknown_term.urn
        @terms << term_report.merge({found: false, refname: unknown_term})
        @cache.put('unknownvalue', type_subtype, val, urn)
        @csid_cache.put('unknownvalue', type_subtype, val, urn)
        urn
      end

      # records the fact that this is an unknown term in the mapper response
      def add_known_unknown_term(val, term_report)
        unknown_term_str = cached_term('unknownvalue', type_subtype, val)
        unknown_term = CollectionSpace::Mapper::UnknownTerm.from_string(unknown_term_str)
        @terms << term_report.merge({found: false, refname: unknown_term})
        add_missing_record_error('term', val)
        unknown_term_str
      end

      # def add_new_unknown_term(val, term_report)
      #   @terms << term_report.merge({found: false, refname: 'null'})
      #   @cache.put('unknownvalue', type_subtype, val, 'null')
      #   'null'
      # end

      # def add_known_unknown_term(val, term_report)
      #   @terms << term_report.merge({found: false, refname: 'null'})
      #   add_missing_record_error('term', val)
      #   'null'
      # end
    end
  end
end

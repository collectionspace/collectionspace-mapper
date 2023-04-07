# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class TermHandler
      include TermSearchable

      attr_reader :result, :terms, :warnings, :errors,
        :column, :source_type, :type, :subtype
      attr_accessor :value

      # @param mapping [CollectionSpace::Mapper::ColumnMapping]
      # @param data [Array<String>]
      # @param client [CollectionSpace::Client]
      # @param mapper [CollectionSpace::Mapper::RecordMapper]
      # @todo appconfig remove client, mapper, searcher args
      def initialize(mapping:, data:, client: nil, mapper: nil, searcher: nil)
        @mapping = mapping
        @data = data
        @client = CollectionSpace::Mapper.client
        @mapper = CollectionSpace::Mapper.recordmapper
        @searcher = CollectionSpace::Mapper.searcher

        @cache = CollectionSpace::Mapper.termcache
        @csid_cache = CollectionSpace::Mapper.csidcache

        @column = mapping.datacolumn
        @field = mapping.fieldname
        @config = CollectionSpace::Mapper.batch
        @source_type = @mapping.source_type.to_sym
        @terms = []
        case @source_type
        when :authority
          authconfig = @mapping.transforms[:authority]
          @type = authconfig[0]
          @subtype = authconfig[1]
        when :vocabulary
          @type = "vocabularies"
          @subtype = @mapping.transforms[:vocabulary]
        end
        @warnings = []
        @errors = []
        handle_terms
      end

      private

      attr_reader :searcher

      def handle_terms
        @result = if @data.first.is_a?(String)
          @data.map { |val| handle_term(val) }
        else
          @data.map { |arr| arr.map { |val| handle_term(val) } }
        end
      end

      def handle_term(val)
        @value = val
        return "" if val.blank? || val == "%NULLVALUE%"
        if val == CollectionSpace::Mapper.bomb
          return CollectionSpace::Mapper.bomb
        end

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
            map_val = refname_urn
          end
        elsif cached_as_unknown?(val)
          add_known_unknown_term(val, term_report)
          added = true
          map_val = ""
        else # not in cache
          refname_urn = searched_term(val, :refname)
          if refname_urn
            add_found_term(refname_urn, term_report)
            added = true
            map_val = refname_urn
          end
        end

        add_new_unknown_term(val, term_report) unless added
        return map_val if map_val

        ""
      end

      def add_found_term(refname_urn, term_report)
        refname_obj = CollectionSpace::Mapper::Tools::RefName.new(
          urn: refname_urn
        )
        found = true
        @terms << term_report.merge({found: found, refname: refname_obj})
      end

      def add_new_unknown_term(val, term_report)
        unknown_term = CollectionSpace::Mapper::UnknownTerm.new(
          type: type,
          subtype: subtype,
          term: val
        )
        urn = unknown_term.urn
        @terms << term_report.merge({found: false, refname: unknown_term})
        add_missing_record_error("term", val)
        [val, case_swap(val)].each { |value|
          @cache.put("unknownvalue", type_subtype, value, urn)
        }
      end

      # records the fact that this is an unknown term in the mapper response
      def add_known_unknown_term(val, term_report)
        unknown_term_str = cached_unknown(type_subtype, val)
        unknown_term = CollectionSpace::Mapper::UnknownTerm.from_string(
          unknown_term_str
        )
        @terms << term_report.merge({found: false, refname: unknown_term})
        add_missing_record_error("term", val)
        unknown_term_str
      end
    end
  end
end

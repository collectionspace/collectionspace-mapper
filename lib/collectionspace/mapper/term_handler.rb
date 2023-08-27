# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class TermHandler
      include TermSearchable

      # @param mapping [CollectionSpace::Mapper::ColumnMapping]
      # @param data [Array<String>]
      # @param handler [CollectionSpace::Mapper::DataHandler]
      # @param response [CollectionSpace::Mapper::Response]
      def initialize(mapping:, data:, handler:, response:)
        @mapping = mapping
        @data = data
        @handler = handler
        @response = response

        @column = mapping.datacolumn
        @field = mapping.fieldname
        @source_type = mapping.source_type.to_sym
        case @source_type
        when :authority
          authconfig = mapping.transforms[:authority]
          @type = authconfig[0]
          @subtype = authconfig[1]
        when :vocabulary
          @type = "vocabularies"
          @subtype = mapping.transforms[:vocabulary]
        end
        response.transformed_data[column] = handle_terms
      end

      private

      attr_reader :mapping, :data, :handler, :response, :column, :source_type,
        :type, :subtype

      def handle_terms
        if data.first.is_a?(String)
          data.map { |val| handle_term(val) }
        else
          data.map { |arr| arr.map { |val| handle_term(val) } }
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
          term: val,
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
          add_known_unknown_term(term_report)
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

        add_new_unknown_term(term_report) unless added
        return map_val if map_val

        ""
      end

      def add_found_term(refname_urn, term_report)
        refname = CollectionSpace::Mapper::Tools::RefName.from_urn(refname_urn)
        opts = term_report.merge({found: true, refname: refname})

        response.add_term(
          CollectionSpace::Mapper::UsedTerm.new(**opts)
        )
      end

      def add_new_unknown_term(term_report)
        val = term_report[:term]
        unknown_term = CollectionSpace::Mapper::UnknownTerm.new(
          type: type,
          subtype: subtype,
          term: val
        )
        urn = unknown_term.urn
        opts = term_report.merge({found: false, refname: unknown_term})
        response.add_term(
          CollectionSpace::Mapper::UsedTerm.new(**opts)
        )
        add_missing_record_error("term", val)
        [val, case_swap(val)].each do |value|
          termcache.put("unknownvalue", type_subtype, value, urn)
        end
      end

      # records the fact that this is an unknown term in the mapper response
      def add_known_unknown_term(term_report)
        val = term_report[:term]
        unknown_term_str = cached_unknown(type_subtype, val)
        unknown_term = CollectionSpace::Mapper::UnknownTerm.from_string(
          unknown_term_str
        )
        opts = term_report.merge({found: false, refname: unknown_term})
        response.add_term(
          CollectionSpace::Mapper::UsedTerm.new(**opts)
        )
        add_missing_record_error("term", val)
        unknown_term_str
      end
    end
  end
end

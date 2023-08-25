# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class Response
      attr_reader :orig_data, :doc,
        :record_status, :csid, :uri, :refname,
        :terms, :errors, :warnings,
        :identifier, :merged_data, :xpaths,
        :split_data, :transformed_data
      attr_accessor :combined_data

      # @param data [Hash, CollectionSpace::Mapper::Response]
      # @param handler [CollectionSpace::Mapper::DataHandler]
      def self.new(data, handler)
        return data if data.is_a?(CollectionSpace::Mapper::Response)

        obj = allocate
        obj.send(:initialize, data, handler)
        obj
      end

      # @param data_hash [Hash]
      # @param handler [CollectionSpace::Mapper::DataHandler]
      def initialize(data_hash, handler)
        @handler = handler
        @orig_data = data_hash
        @errors = []
        @warnings = []
        @merged_data = prepare_merged_data
        @states = %i[defaults_merged merged_keys_downcased]
        @xpaths = set_xpaths
        @split_data = {}
        @transformed_data = {}
        @combined_data = {}
        @doc = nil
        @terms = []
        @identifier = ""
      end

      def add_doc(doc)
        @doc = doc
      end

      def add_identifier(id)
        @identifier = id
      end

      def add_error(error)
        errors << error
        @errors = errors.flatten.compact
      end

      def add_term(term)
        terms << term
        @terms = terms.flatten.compact
      end

      def add_warning(warning)
        warnings << warning
        @warnings = warnings.flatten.compact
      end

      def dup
        newobj = clone
        instance_variables.each do |ivar|
          newobj.instance_variable_set(
            ivar,
            instance_variable_get(ivar).clone
          )
        end
        newobj
      end

      def valid?
        validate unless states.any?(:validated)
        errors.empty?
      end

      def set_record_status
        if handler.batch.check_record_status
          result = handler.status_checker.call(status_check_id)
          @record_status = result[:status]
          @csid = result[:csid]
          @uri = result[:uri]
          @refname = result[:refname]
        else
          @record_status = :new
        end
      end

      def tag_terms
        return if terms.empty?

        record_new_missing_terms
        # unless cached_unknown_terms.empty?
        #   mark_cached_unknown_terms_as_not_found
        # end
      end

      def normal
        @merged_data = {}
        @split_data = {}
        @transformed_data = {}
        @combined_data = {}
        @terms = @terms.map(&:to_h)
        self
      end

      def xml
        doc&.to_xml
      end

      def validate
        return self if states.any?(:validated)

        handler.validator.validate(self)
        states << :validated
        self
      end

      def prep
        return self if states.any?(:prepped_for_mapping)
        return self unless valid?

        states << :prepped_for_mapping
        handler.prepper_class.new(self, handler).prep
      end

      def map
        return self if states.any?(:mapped)

        prep unless states.any?(:prepped_for_mapping)
        return self unless valid?

        # Remove blank/empty values before mapping
        @transformed_data = transformed_data.delete_if do |_key, value|
          value.nil? || value.empty?
        end

        CollectionSpace::Mapper::DataMapper.new(self, handler)
        tag_terms
        set_record_status
        states << :mapped
        if handler.batch.response_mode == "normal"
          normal
        else
          self
        end
      end

      def add_multi_rec_found_warning(num_found)
        msg = "#{num_found} records found for #{identifier}. Using first "\
          "record found: #{uri}"
        warnings << {
          category: :multiple_records_found_for_id,
          field: nil,
          type: nil,
          subtype: nil,
          value: nil,
          message: msg
        }
      end

      private

      attr_reader :handler, :states

      def prepare_merged_data
        merged = merge_default_values

        merged.transform_keys(&:downcase)
      end

      def merge_default_values
        defaults = handler.batch.default_values
        return orig_data unless defaults

        to_merge = if handler.batch.force_defaults
          defaults
        else
          non_forced_defaults(defaults)
        end
        orig_data.merge(to_merge)
      end

      def non_forced_defaults(default_vals)
        default_vals.map { |field, val|
          origval = orig_data[field]
          if origval.nil? || origval.empty?
            [field, val]
          end
        }.compact.to_h
      end

      def set_xpaths
        return if states.any?(:xpaths_set)
        return nil unless valid?

        states << :xpaths_set
        handler.record.xpaths.for_row(merged_data)
      end

      def cached_unknown_terms
        found_terms.select do |term|
          handler.new_terms.key?(term.key)
        end
      end

      def found_terms
        terms.select { |term| term.found? }
      end

      def missing_terms
        terms.select { |term| !term.found? }
      end

      def record_new_missing_terms
        missing_terms.each do |term|
          handler.new_terms[term.key] = nil
        end
      end

      def status_check_id
        case handler.record.service_type
        when "relation"
          {
            sub: combined_data["relations_common"]["subjectCsid"][0],
            obj: combined_data["relations_common"]["objectCsid"][0],
            prd: combined_data["relations_common"]["relationshipType"][0]
          }
        when "authority"
          split_data["termdisplayname"].first
        else
          identifier
        end
      end
    end
  end
end

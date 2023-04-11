# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class Response
      attr_reader :orig_data, :doc, :xphash,
        :record_status, :csid, :uri, :refname,
        :terms, :errors, :warnings,
        :identifier
      attr_accessor :split_data, :merged_data, :transformed_data,
        :combined_data

      # @param data [Hash, CollectionSpace::Mapper::Response]
      def self.new(
        data,
        status_checker = CollectionSpace::Mapper.status_checker,
        validator = CollectionSpace::Mapper.validator
      )
        return data if data.is_a?(CollectionSpace::Mapper::Response)

        obj = allocate
        obj.send(:initialize, data, status_checker, validator)
        obj
      end

      def initialize(
        data_hash,
        status_checker = CollectionSpace::Mapper.status_checker,
        validator = CollectionSpace::Mapper.validator
      )
        return data_hash if data_hash.is_a?(Response)

        @orig_data = data_hash
        @status_checker = status_checker
        @validator = validator
        @merged_data = merge_default_values
        @split_data = {}
        @transformed_data = {}
        @combined_data = {}
        @doc = nil
        @errors = []
        @warnings = []
        @terms = []
        @identifier = ""
        @states = %i[defaults_merged merged_keys_downcased]
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

      def add_warning(warning)
        warnings << warning
        @warnings = warnings.flatten.compact
      end

      def add_xphash(hash)
        @xphash = hash
      end

      def dup
        newobj = self.clone
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
        if CollectionSpace::Mapper.batch.check_record_status
          result = status_checker.call(self)
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

        validator.validate(self)
        states << :validated
        self
      end

      def prep
        return self if states.any?(:prepped_for_mapping)

        validate unless states.any?(:validated)
        return self unless valid?

        states << :prepped_for_mapping
        CollectionSpace::Mapper.prepper_class.new(self).prep
      end

      def map
        return self if states.any?(:mapped)

        prep unless states.any?(:prepped_for_mapping)
        # @todo This should not produce XML for records with ERRORS,
        #   but it is a behavior change that might be unexpected. Revisit.
        # return self unless valid?

        CollectionSpace::Mapper::DataMapper.new(self)
        tag_terms
        set_record_status
        states << :mapped
        if CollectionSpace::Mapper.batch.response_mode == "normal"
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

      attr_reader :states, :status_checker, :validator

      def merge_default_values
        defaults = CollectionSpace::Mapper.batch.default_values
        return data unless defaults

        if CollectionSpace::Mapper.batch.force_defaults
          to_merge = defaults
        else
          to_merge = non_forced_defaults(defaults)
        end
        merged = orig_data.merge(to_merge)
        merged.transform_keys(&:downcase)
      end

      def non_forced_defaults(default_vals)
        default_vals.map{ |field, val|
          origval = orig_data[field]
          if origval.nil? || origval.empty?
            [field, val]
          else
            nil
          end
        }.compact.to_h
      end

      def cached_unknown_terms
        found_terms.select do |term|
          CollectionSpace::Mapper.new_terms.key?(term.key)
        end
      end

      def found_terms
        terms.select{ |term| term.found? }
      end

      # # @todo this should be
      # def mark_cached_unknown_terms_as_not_found
      #   cached_unknown_terms.each{ |term| !term.found? }
      # end

      def missing_terms
        terms.select{ |term| !term.found? }
      end

      def record_new_missing_terms
        missing_terms.each do |term|
          CollectionSpace::Mapper.new_terms[term.key] = nil
        end
      end
    end
  end
end

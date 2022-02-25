# frozen_string_literal: true

require 'collectionspace/mapper/tools/record_status_service'
require 'collectionspace/mapper/tools/dates'

module CollectionSpace
  module Mapper
    # given a RecordMapper hash and a data hash, returns CollectionSpace XML document
    class DataHandler
      # this is an accessor rather than a reader until I refactor away the hideous
      #  xpath hash
      attr_accessor :mapper

      def initialize(record_mapper:, client:, cache: nil, csid_cache: nil, config: {})
        @mapper = CollectionSpace::Mapper::RecordMapper.new(mapper: record_mapper, batchconfig: config,
                                                            csclient: client, termcache: cache)
        @mapper.xpath = xpath_hash
        merge_config_transforms
        @new_terms = {}
        @status_checker = CollectionSpace::Mapper::Tools::RecordStatusService.new(@mapper.csclient, @mapper)
      end

      def process(data)
        prepped = prep(data)
        case @mapper.record_type
        when 'nonhierarchicalrelationship'
          prepped.responses.map{ |response| map(response, prepped.xphash) }
        else
          map(prepped.response, prepped.xphash)
        end
      end

      def prep(data)
        response = CollectionSpace::Mapper.setup_data(data, @mapper.batchconfig)
        if response.valid?
          case @mapper.record_type
          when 'authorityhierarchy'
            prepper = CollectionSpace::Mapper::AuthorityHierarchyPrepper.new(response, self)
            prepper.prep
          when 'nonhierarchicalrelationship'
            prepper = CollectionSpace::Mapper::NonHierarchicalRelationshipPrepper.new(response, self)
            prepper.prep
          when 'objecthierarchy'
            prepper = CollectionSpace::Mapper::ObjectHierarchyPrepper.new(response, self)
            prepper.prep
          else
            prepper = CollectionSpace::Mapper::DataPrepper.new(response, self)
            prepper.prep
          end
        else
          response
        end
      end

      def map(response, xphash)
        mapper = CollectionSpace::Mapper::DataMapper.new(response, self, xphash)
        result = mapper.response
        tag_terms(result)
        @mapper.batchconfig.check_record_status ? set_record_status(result) : result.record_status = :new
        @mapper.batchconfig.response_mode == 'normal' ? result.normal : result
      end

      def check_fields(data)
        data_fields = data.keys.map(&:downcase)
        unknown = data_fields - @mapper.mappings.known_columns
        known = data_fields - unknown
        {known_fields: known, unknown_fields: unknown}
      end

      # this is surfaced in public interface because it is used by cspace-batch-import
      def service_type
        @mapper.config.service_type
      end

      def validate(data)
        response = CollectionSpace::Mapper.setup_data(data, @mapper.batchconfig)
        validator.validate(response)
      end

      def mappings
        @mapper.mappings
      end

      def setup_xpath_hash_structure
        xhash = {}
        # create key for each xpath containing fields, and set up structure of its value
        mappings.each do |mapping|
          xhash[mapping.fullpath] =
            {parent: '', children: [], is_group: false, is_subgroup: false, subgroups: [], mappings: []}
        end
        xhash
      end

      def associate_mappings_with_xpaths(xhash)
        mappings.each do |mapping|
          xhash[mapping.fullpath][:mappings] << mapping
        end
        xhash
      end

      # builds hash containing information to be used in mapping the fields that are
      #  children of each xpath
      # keys - the XML doc xpaths that contain child fields
      # value is a hash with the following keys:
      #  :parent - String, xpath of parent (empty if it's a top level namespace)
      #  :children - Array, of xpaths occuring beneath this one in the document
      #  :is_group - Boolean, whether grouping of fields at xpath is a repeating field group
      #  :is_subgroup - Boolean, whether grouping of fields is subgroup of another group
      #  :subgroups - Array, xpaths of any repeating field groups that are children of an xpath
      #     that itself contains direct child fields
      #  :mappings - Array, of fieldmappings that are children of this xpath
      def xpath_hash
        xhash = setup_xpath_hash_structure
        h = associate_mappings_with_xpaths(xhash)

        # populate parent of all non-top xpaths
        h.each do |xpath, ph|
          next unless xpath['/']

          keys = h.keys - [xpath]
          keys = keys.select{ |k| xpath[k] }
          keys = keys.sort{ |a, b| b.length <=> a.length }
          ph[:parent] = keys[0] unless keys.empty?
        end

        # populate children
        h.each do |xpath, ph|
          keys = h.keys - [xpath]
          ph[:children] = keys.select{ |k| k.start_with?(xpath) }
        end

        # populate subgroups
        h.each do |xpath, ph|
          keys = h.keys - [xpath]
          subpaths = keys.select{ |k| k.start_with?(xpath) }
          subpaths.each{ |p| ph[:subgroups] << p } if !subpaths.empty? && !ph[:parent].empty?
        end

        # populate is_group
        h.each do |xpath, ph|
          ct = ph[:mappings].size
          v = ph[:mappings].map{ |mapping| mapping.in_repeating_group }.uniq
          ph[:is_group] = true if v == ['y']
          if v.size > 1
            puts "WARNING: #{xpath} has fields with different :in_repeating_group values (#{v}). Defaulting to treating NOT as a group"
          end
          if ct == 1 && v == ['as part of larger repeating group'] && ph[:mappings][0].repeats == 'y'
            ph[:is_group] =
              true
          end
        end

        # populate is_subgroup
        subgroups = []
        h.each{ |_k, v| subgroups << v[:subgroups] }
        subgroups = subgroups.flatten.uniq
        h.keys.each{ |k| h[k][:is_subgroup] = true if subgroups.include?(k) }
        h
      end

      private

      def set_record_status(response)
        if @mapper.service_type == CS::Mapper::Authority
          value = response.split_data['termdisplayname'].first
        elsif @mapper.service_type == CS::Mapper::Relationship
          value = {}
          value[:sub] = response.combined_data['relations_common']['subjectCsid'][0]
          value[:obj] = response.combined_data['relations_common']['objectCsid'][0]
        else
          value = response.identifier
        end

        begin
          searchresult = @status_checker.lookup(value)
        rescue CollectionSpace::Mapper::MultipleCsRecordsFoundError => e
          err = {
            category: :multiple_matching_recs,
            field: @mapper.config.search_field,
            type: nil,
            subtype: nil,
            value: value,
            message: e.message
          }
          response.errors << err
        else
          status = searchresult[:status]
          response.record_status = status
          return if status == :new

          response.csid = searchresult[:csid]
          response.uri = searchresult[:uri]
          response.refname = searchresult[:refname]
          num_found = searchresult[:multiple_recs_found]
          return unless num_found

          response.add_multi_rec_found_warning(num_found)
        end
      end

      def tag_terms(result)
        terms = result.terms
        return if terms.empty?

        terms.select{ |t| !t[:found] }.each do |term|
          @new_terms[CollectionSpace::Mapper.term_key(term)] = nil
        end
        terms.select{ |t| t[:found] }.each do |term|
          term[:found] = false if @new_terms.key?(CollectionSpace::Mapper.term_key(term))
        end

        result.terms = terms
      end

      def validator
        @validator ||= CS::Mapper::DataValidator.new(@mapper, @mapper.termcache)
      end

      # you can specify per-data-key transforms in your config.json
      # This method merges the config.json transforms into the CollectionSpace::Mapper::RecordMapper field
      #   mappings for the appropriate fields
      def merge_config_transforms
        return unless @mapper.batchconfig.transforms

        @mapper.batchconfig.transforms.transform_keys!(&:downcase)
        @mapper.batchconfig.transforms.each do |data_column, transforms|
          target_mapping = transform_target(data_column)
          next unless target_mapping

          target_mapping.update_transforms(transforms)
        end
      end

      def transform_target(data_column)
        @mapper.mappings.select{ |field_mapping| field_mapping.datacolumn == data_column }.first
      end
    end
  end
end

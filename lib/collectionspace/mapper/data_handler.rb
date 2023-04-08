# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # given a RecordMapper hash and a data hash, returns CollectionSpace XML
    #   document
    # @todo Manipulation of recordmapper's xpath_hash belongs on recordmapper
    class DataHandler
      attr_reader :date_handler, :searcher, :mapper

      def initialize(record_mapper:, client:, cache:, csid_cache:, config: {})
        CollectionSpace::Mapper.config.client = client
        CollectionSpace::Mapper.config.termcache = cache
        CollectionSpace::Mapper.config.csidcache = csid_cache
        CollectionSpace::Mapper.config.batchconfigraw = config

        CollectionSpace::Mapper::RecordMapper.new(
          mapper: record_mapper,
          batchconfig: config,
          csclient: client,
          termcache: cache,
          csidcache: csid_cache
        )
        @mapper = CollectionSpace::Mapper.recordmapper

        # initializing the RecordMapper causes app config record config
        #   settings to be populated, including :recordtype

        CollectionSpace::Mapper.config.batchconfig =
          CollectionSpace::Mapper::Config.new(
            config: CollectionSpace::Mapper.batchconfigraw,
            record_type: CollectionSpace::Mapper.record.recordtype
          )

        validator = CollectionSpace::Mapper::DataValidator.new(
          CollectionSpace::Mapper.recordmapper,
          CollectionSpace::Mapper.termcache
        )
        CollectionSpace::Mapper.config.validator = validator
        @validator = validator

        searcher = CollectionSpace::Mapper::Searcher.new(
          client: CollectionSpace::Mapper.client,
          config: CollectionSpace::Mapper.batchconfig
        )
        CollectionSpace::Mapper.config.searcher = searcher
        @searcher = searcher

        prepper_class = determine_prepper_class
        CollectionSpace::Mapper.config.prepper_class = prepper_class
        @prepper_class = CollectionSpace::Mapper.prepper_class

        date_handler =
          CollectionSpace::Mapper::Dates::StructuredDateHandler.new(
            client: CollectionSpace::Mapper.client,
            cache: CollectionSpace::Mapper.termcache,
            csid_cache: CollectionSpace::Mapper.csidcache,
            config: CollectionSpace::Mapper.batchconfig,
            searcher: CollectionSpace::Mapper.searcher
          )
        CollectionSpace::Mapper.config.date_handler = date_handler
        @date_handler = date_handler

        CollectionSpace::Mapper.recordmapper.xpath = xpath_hash
        merge_config_transforms
        @new_terms = {}
        @status_checker =
          CollectionSpace::Mapper::Tools::RecordStatusServiceBuilder.call(
            client: CollectionSpace::Mapper.client,
            mapper: CollectionSpace::Mapper.recordmapper
          )

        CollectionSpace::Mapper.config.data_handler = self
      end

      def process(data)
        prepped = prep(data)
        case CollectionSpace::Mapper.record.recordtype
        when "nonhierarchicalrelationship"
          prepped.responses.map { |response| map(response, prepped.xphash) }
        else
          map(prepped.response, prepped.xphash)
        end
      end

      def determine_prepper_class
        case CollectionSpace::Mapper.record.recordtype
        when "authorityhierarchy"
          CollectionSpace::Mapper::AuthorityHierarchyPrepper
        when "nonhierarchicalrelationship"
          CollectionSpace::Mapper::NonHierarchicalRelationshipPrepper
        when "objecthierarchy"
          CollectionSpace::Mapper::ObjectHierarchyDataPrepper
        else
          CollectionSpace::Mapper::DataPrepper
        end
      end

      def prep(data)
        response = CollectionSpace::Mapper.setup_data(
          data,
          CollectionSpace::Mapper.batchconfig
        )
        if response.valid?
          prepper_class.new(response).prep
        else
          response
        end
      end

      # @todo move to a method on Response
      def map(response, xphash)
        mapper = CollectionSpace::Mapper::DataMapper.new(response, self, xphash)
        result = mapper.response
        tag_terms(result)
        if CollectionSpace::Mapper.batch.check_record_status
          set_record_status(result)
        else
          result.record_status = :new
        end
        (CollectionSpace::Mapper.batch.response_mode == "normal") ? result.normal : result
      end

      def check_fields(data)
        data_fields = data.keys.map(&:downcase)
        unknown = data_fields - @mapper.mappings.known_columns
        known = data_fields - unknown
        {known_fields: known, unknown_fields: unknown}
      end

      # this is surfaced in public interface because it is used by
      #   cspace-batch-import
      def service_type
        CollectionSpace::Mapper.record.service_type
      end

      # @todo move to a method on Response
      def validate(data)
        validator.validate(data)
      end

      def mappings
        CollectionSpace::Mapper.recordmapper.mappings
      end

      def setup_xpath_hash_structure
        xhash = {}
        # create key for each xpath containing fields, and set up structure of
        #   its value
        mappings.each do |mapping|
          xhash[mapping.fullpath] =
            {parent: "", children: [], is_group: false, is_subgroup: false,
             subgroups: [], mappings: []}
        end
        xhash
      end

      def associate_mappings_with_xpaths(xhash)
        mappings.each do |mapping|
          xhash[mapping.fullpath][:mappings] << mapping
        end
        xhash
      end

      # builds hash containing information to be used in mapping the fields that
      #   are children of each xpath
      # keys - the XML doc xpaths that contain child fields
      # value is a hash with the following keys:
      #  :parent - String, xpath of parent (empty if it's a top level namespace)
      #  :children - Array, of xpaths occuring beneath this one in the document
      #  :is_group - Boolean, whether grouping of fields at xpath is a repeating
      #   field group
      #  :is_subgroup - Boolean, whether grouping of fields is subgroup of
      #   another group
      #  :subgroups - Array, xpaths of any repeating field groups that are
      #   children of an xpath that itself contains direct child fields
      #  :mappings - Array, of fieldmappings that are children of this xpath
      def xpath_hash
        xhash = setup_xpath_hash_structure
        h = associate_mappings_with_xpaths(xhash)

        # populate parent of all non-top xpaths
        h.each do |xpath, ph|
          next unless xpath["/"]

          keys = h.keys - [xpath]
          keys = keys.select { |k| xpath[k] }
          keys = keys.sort { |a, b| b.length <=> a.length }
          ph[:parent] = keys[0] unless keys.empty?
        end

        # populate children
        h.each do |xpath, ph|
          keys = h.keys - [xpath]
          ph[:children] = keys.select { |k| k.start_with?(xpath) }
        end

        # populate subgroups
        h.each do |xpath, ph|
          keys = h.keys - [xpath]
          subpaths = keys.select { |k| k.start_with?(xpath) }
          if !subpaths.empty? && !ph[:parent].empty?
            subpaths.each { |p|
              ph[:subgroups] << p
            }
          end
        end

        # populate is_group
        h.each do |xpath, ph|
          ct = ph[:mappings].size
          v = ph[:mappings].map { |mapping| mapping.in_repeating_group }.uniq
          ph[:is_group] = true if v == ["y"]
          if v.size > 1
            puts "WARNING: #{xpath} has fields with different :in_repeating_"\
              "group values (#{v}). Defaulting to treating NOT as a group"
          end
          if ct == 1 &&
              v == ["as part of larger repeating group"] &&
              ph[:mappings][0].repeats == "y"
            ph[:is_group] = true
          end
        end

        # populate is_subgroup
        subgroups = []
        h.each { |_k, v| subgroups << v[:subgroups] }
        subgroups = subgroups.flatten.uniq
        h.keys.each { |k| h[k][:is_subgroup] = true if subgroups.include?(k) }
        h
      end

      def to_s
        cfg = mapper.config
        id = "#{cfg.recordtype} #{mapper.csclient.config.base_uri}"
        "<##{self.class}:#{object_id.to_s(8)} #{id}>"
      end

      private

      attr_reader :validator, :prepper_class

      def set_record_status(response)
        response.merge_status_data(@status_checker.call(response))
      end

      def tag_terms(result)
        terms = result.terms
        return if terms.empty?

        terms.select { |t| !t[:found] }.each do |term|
          @new_terms[term[:refname].key] = nil
        end
        terms.select { |t| t[:found] }.each do |term|
          term[:found] = false if @new_terms.key?(term[:refname].key)
        end

        result.terms = terms
      end

      # you can specify per-data-key transforms in your config.json
      # This method merges the config.json transforms into the
      #   CollectionSpace::Mapper::RecordMapper field mappings for the
      #   appropriate fields
      def merge_config_transforms
        transforms = CollectionSpace::Mapper.batch.transforms
        return if transforms.nil? || transforms.empty?

        transforms.transform_keys!(&:downcase)
        transforms.each do |data_column, transforms|
          target_mapping = transform_target(data_column)
          next unless target_mapping

          target_mapping.update_transforms(transforms)
        end
      end

      def transform_target(data_column)
        CollectionSpace::Mapper.recordmapper.mappings
          .find { |field_mapping| field_mapping.datacolumn == data_column }
      end
    end
  end
end

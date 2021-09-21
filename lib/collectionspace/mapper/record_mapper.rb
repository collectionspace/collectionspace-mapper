# frozen_string_literal: true

require 'collectionspace/mapper/tools/symbolizable'

module CollectionSpace
  module Mapper

    # Represents a JSON RecordMapper containing the config, field mappings, and template
    #  for transforming a hash of data into CollectionSpace XML
    # The RecordMapper bundles up all the info needed by various other classes in order
    #  to transform and map incoming data into CollectionSpace XML, so it gets passed
    #  around to everything as a kind of mondo-configuration-object, which is probably
    #  terrible OOD but better than what I had before? 

    # :reek:Attribute - when I get rid of xphash, this will go away
    # :reek:InstanceVariableAssumption - instance variable gets set by convert
    class RecordMapper
      include Tools::Symbolizable
      
      attr_reader :batchconfig, :config, :mappings, :xml_template, :csclient

      attr_accessor :xpath
      
      def initialize(opts)
        jhash = opts[:mapper].is_a?(Hash) ? opts[:mapper] : JSON.parse(opts[:mapper])
        convert(jhash)
        @batchconfig = CS::Mapper::Config.new(config: opts[:batchconfig], record_type: record_type_extension)
        @csclient = opts[:csclient]
        @termcache = opts[:termcache] || nil
        @xpath = {}
      end

      def termcache
        @termcache ||= get_termcache
      end

      def csidcache
        @csidcache ||= get_csidcache
      end
      
      def record_type
        @config.recordtype
      end

      # The value returned here is used to enable module extension when creating
      #  other classes using RecordMapper
      def service_type
        case @config.service_type
        when 'authority'
          CS::Mapper::Authority
        when 'relation'
          CS::Mapper::Relationship
        when 'procedure'
          record_type_extension
        end
      end
      
      private

      def convert(json)
        hash = symbolize(json)
        @config = CS::Mapper::RecordMapperConfig.new(hash[:config])
        @xml_template = CS::Mapper::XmlTemplate.new(hash[:docstructure])
        @mappings = CS::Mapper::ColumnMappings.new(mappings: hash[:mappings],                             
                                                   mapper: self)
      end

      def get_termcache
        config = {
          domain: @csclient.domain,
          error_if_not_found: false,
          lifetime: 5 * 60,
          search_delay: 5 * 60,
          search_enabled: true
        }
        # search for authority records by display name, not short ID
        config[:search_identifiers] = service_type == CS::Mapper::Authority ? false : true
        CollectionSpace::RefCache.new(config: config, client: @csclient)
      end

      def get_csidcache
        return nil unless service_type == CS::Mapper::Relationship
        
        config = {
          domain: @csclient.domain,
          error_if_not_found: false,
          lifetime: 5 * 60,
          search_delay: 5 * 60,
          search_enabled: false
        }
        CollectionSpace::RefCache.new(config: config, client: @csclient)
      end

      def record_type_extension
        case record_type
        when 'media'
          CS::Mapper::Media
        when 'objecthierarchy'
          CS::Mapper::ObjectHierarchy
        when 'authorityhierarchy'
          CS::Mapper::AuthorityHierarchy
        when 'nonhierarchicalrelationship'
          CS::Mapper::NonHierarchicalRelationship
        end
      end
    end
  end
end

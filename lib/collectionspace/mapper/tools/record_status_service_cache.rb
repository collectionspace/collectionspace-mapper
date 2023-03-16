# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      # Returns status of records, based on presence in CSID Cache.
      # @note This should **only** be used with expert migration tooling with which you can
      #   confidently ensure the CSID Cache is accurately populated with all existing records
      class RecordStatusServiceCache < CollectionSpace::Mapper::Tools::RecordStatusServiceBuilder
        def initialize(mapper)
          super
          @refname_cache = mapper.termcache
          @csid_cache = mapper.csidcache
        end

        def call(response)
          value = get_value_for_record_status(response)
          if authority?
            lookup_authority(value)
          elsif type == "collectionobjects"
            lookup_object(value)
          elsif mapper.config.service_type == "relation"
            lookup_relation(value)
          else
            lookup_procedure(value)
          end
        end
        # rectype = mapper.config.recordtype

        private

        attr_reader :refname_cache, :csid_cache

        def lookup_authority(term)
          csid = csid_cache.get_auth_term(type, subtype, term)
          refname = refname_cache.get_auth_term(type, subtype, term)

          if csid || refname
            reportable_result({"csid" => csid, "refName" => refname})
          else
            reportable_result
          end
        end

        def lookup_object(identifier)
          csid = csid_cache.get_object(identifier)
          csid ? reportable_result({"csid" => csid}) : reportable_result
        end

        def lookup_procedure(identifier)
          csid = csid_cache.get_procedure(type, identifier)
          csid ? reportable_result({"csid" => csid}) : reportable_result
        end

        def lookup_relation(rel_hash)
          csid = csid_cache.get_relation(relation_type(rel_hash),
            rel_hash[:sub], rel_hash[:obj])
          csid ? reportable_result({"csid" => csid}) : reportable_result
        end

        def relation_type(rel_hash)
          prd = rel_hash[:prd]
          return "hier" if prd == "hasBroader"

          "nhr"
        end
      end
    end
  end
end

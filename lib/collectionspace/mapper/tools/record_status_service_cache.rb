# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      class RecordStatusServiceCache < CS::Mapper::Tools::RecordStatusServiceBuilder
        def initialize(mapper)
          super
          @refname_cache = mapper.termcache
          @csid_cache = mapper.csidcache
        end
        
        def call(response)
          value = get_value_for_record_status(response)
          if authority?
            lookup_authority(value)
          end
        end    
        #rectype = mapper.config.recordtype
        private

        attr_reader :refname_cache, :csid_cache

        def lookup_authority(term)
          csid = csid_cache.get_auth_term(type, subtype, term)
          refname = refname_cache.get_auth_term(term, subtype, term)

          if csid || refname
            reportable_result({'csid' => csid, 'refname' => refname})
          else
            reportable_result
          end
        end
        
      end
    end
  end
end


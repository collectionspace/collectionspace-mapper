# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # Mixin module to organize caching-related methods.
    # @note Implementation assumes this module will be included in a class or
    #   module with the `handler` method
    module Cacheable
      include CaseSwappable
      include TypeSubtypeable

      private

      def cache_mode = if handler.respond_to?(:termcache) &&
          handler.respond_to?(:csidcache)
                         :separate
                       else
                         :allinone
                       end

      def cache(value_type)
        return combinedcache if cache_mode == :allinone

        case value_type
        when :refname then termcache
        when :csid then csidcache
        end
      end

      def termcache
        return nil unless handler.respond_to?(:termcache)

        handler.termcache
      end

      def csidcache
        return nil unless handler.respond_to?(:csidcache)

        handler.csidcache
      end

      def combinedcache
        return nil unless handler.respond_to?(:cache)

        handler.cache
      end

      # @param val [String]
      # @return [Boolean] whether or not refname for term is stored in cache
      def in_cache?(val)
        this_cache = cache(:refname)
        args = [type, subtype, val]
        args << "refname" if cache_mode == :allinone

        return true if this_cache.send(:exists?, *args)
        return true if this_cache.send(:exists?, *case_swap_element(args, 2))

        false
      end

      # @param val [String]
      # @return [Boolean] whether value is cached as an unknownvalue
      def cached_as_unknown?(val)
        this_cache = cache(:refname)
        args = ["unknownvalue", type_subtype, val]
        args << "refname" if cache_mode == :allinone

        return true if this_cache.send(:exists?, *args)
        return true if this_cache.send(:exists?, *case_swap_element(args, 2))

        false
      end

      def cached_unknown(type_subtype, val)
        this_cache = cache(:refname)
        args = ["unknownvalue", type_subtype, val]
        args << "refname" if cache_mode == :allinone

        returned = this_cache.send(:get, *args)
        return returned if returned

        this_cache.send(:get, *case_swap_element(args, 2))
      end

      # @param val [String] term display name to get refName for
      # @param termtype [nil, String] authority type
      # @param termsubtype [nil, String] authority subtype
      # @return [String] refName of cached term
      def cached_term(val, termtype = type, termsubtype = subtype)
        this_cache = cache(:refname)
        args = [termtype, termsubtype, val]
        args << "refname" if cache_mode == :allinone

        returned = this_cache.send(:get, *args)
        return returned if returned

        this_cache.send(:get, *case_swap_element(args, 2))
      end

      # @param val [String] term display name to get refName for
      # @param termtype [nil, String] authority type
      # @param termsubtype [nil, String] authority subtype
      # @return [String] csid of cached term
      def cached_term_csid(val, termtype = type, termsubtype = subtype)
        this_cache = cache(:csid)
        args = [termtype, termsubtype, val]
        args << "csid" if cache_mode == :allinone

        returned = this_cache.send(:get, *args)
        return returned if returned

        this_cache.send(:get, *case_swap_element(args, 2))
      end

      # @param term_args [Array] term type, subtype, value
      # @param hash [Hash{[:refname, :csid] => String}]
      def cache_term_values(term_args, hash)
        hash.each do |value_type, value|
          cache_term_value(term_args, value_type, value)
        end
      end

      # @param term_args [Array] term type, subtype, value
      # @param value_type [:csid, :refname]
      # @param value [String]
      def cache_term_value(term_args, value_type, value)
        this_cache = cache(value_type)
        args = term_args + [value]
        args << value_type.to_s if cache_mode == :allinone
        this_cache.send(:put, *args)
      end

      # @param idval [String] identifier field value of object or procedure
      # @param type [String] record type name
      # @return [String] csid of given object or procedure
      def cached_obj_or_procedure_csid(idval, type)
        this_cache = cache(:csid)
        args = [type, "", idval]
        args << "csid" if cache_mode == :allinone
        this_cache.send(:get, *args)
      end

      # @param idval [String] identifier field value of object or procedure
      # @param type [String] record type name
      # @param csid [String] the value to cache
      def cache_obj_or_procedure_csid(idval, type, csid)
        this_cache = cache(:csid)
        args = [type, "", idval, csid]
        args << "csid" if cache_mode == :allinone
        this_cache.send(:put, *args)
      end

      # @param idval [String] identifier field value of object or procedure
      # @param type [String] record type name
      # @param refname [String] the value to cache
      def cache_obj_or_procedure_refname(idval, type, refname)
        this_cache = cache(:refname)
        args = [type, "", idval, refname]
        args << "refname" if cache_mode == :allinone
        this_cache.send(:put, *args)
      end

      def cache_unknown_term(term, cacheval)
        this_cache = cache(:refname)
        args = ["unknownvalue", type_subtype, term, cacheval]
        args << "refname" if cache_mode == :allinone
        this_cache.send(:put, *args)
      end
    end
  end
end

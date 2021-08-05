# frozen_string_literal: true

require 'bundler/setup'
require 'time_up'
require 'pry'

require 'collectionspace/mapper'
require 'facets/array/before'
require_relative '../../spec/helpers'

config = {delimiter: ';'}
mapper_path = File.join('..', '..', 'spec', 'fixtures', 'benchmarking', 'core_collectionobject', 'core_6-1-0_collectionobject.json')
rec_mapper = Helpers.get_json_record_mapper(mapper_path)
client = Helpers.core_client

cache_config = {
  domain: 'core.collectionspace.org',
  search_enabled: false,
  search_identifiers: false
}

cache = CollectionSpace::RefCache.new(config: cache_config, client: client)
popcache = CollectionSpace::RefCache.new(config: cache_config, client: client)
Helpers.populate_core(popcache)


def handler_reusing_cache(mapper, cache, client, config)
  TimeUp.start(:hdlr_chc_reuse) do
    h = handler(mapper, cache, client, config)
    c = h.mapper.termcache
  end
end

def handler_reusing_popcache(mapper, cache, client, config)
  TimeUp.start(:hdlr_popchc_reuse) do
    h = handler(mapper, cache, client, config)
    c = h.mapper.termcache
  end
end

def handler_new_cache(mapper, client, config)
  TimeUp.start(:hdlr_chc_new) do
    h = handler(mapper, nil, client, config)
    c = h.mapper.termcache
  end
end

def handler(mapper, cache, client, config)
  CS::Mapper::DataHandler.new(record_mapper: mapper, cache: cache, client: client, config: config)
end

50.times do
  handler_reusing_popcache(rec_mapper, popcache, client, config)
  handler_new_cache(rec_mapper, client, config)
  handler_reusing_cache(rec_mapper, cache, client, config)
end

TimeUp.print_detailed_summary

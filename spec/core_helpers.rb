# frozen_string_literal: true

require_relative "./helpers"

module Helpers
  def core_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: "https://core.dev.collectionspace.org/cspace-services",
        username: "admin@core.collectionspace.org",
        password: "Administrator"
      )
    )
  end
  memo_wise(:core_client)

  def core_object_mapper
    path = "spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_collectionobject.json"
    get_record_mapper_object(path, core_cache)
  end

  def core_cache
    cache_config = base_cache_config.merge({domain: core_client.domain})
    cache = CollectionSpace::RefCache.new(config: cache_config)
    populate(cache, cacheable_refnames("core.collectionspace.org"))
  end
  memo_wise(:core_cache)

  def core_csid_cache
    cache_config = base_cache_config.merge({domain: core_client.domain})
    cache = CollectionSpace::RefCache.new(config: cache_config)
    populate(cache, cacheable_csids)
  end
  memo_wise(:core_csid_cache)
end

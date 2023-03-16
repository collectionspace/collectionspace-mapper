# frozen_string_literal: true

module Helpers
  def anthro_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: "https://anthro.dev.collectionspace.org/cspace-services",
        username: "admin@anthro.collectionspace.org",
        password: "Administrator"
      )
    )
  end
  memo_wise(:anthro_client)

  def anthro_cache
    cache_config = base_cache_config.merge({domain: anthro_client.domain})
    cache = CollectionSpace::RefCache.new(config: cache_config)
    populate(cache, cacheable_refnames("anthro.collectionspace.org"))
  end
  memo_wise(:anthro_cache)

  def anthro_csid_cache
    cache_config = base_cache_config.merge({domain: anthro_client.domain})
    cache = CollectionSpace::RefCache.new(config: cache_config)
    populate(cache, cacheable_csids)
  end
  memo_wise(:anthro_csid_cache)

  def anthro_object_mapper
    path = "spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_collectionobject.json"
    get_record_mapper_object(path)
  end

  def anthro_co_1
    get_datahash(path: "spec/fixtures/files/datahashes/anthro/collectionobject1.json")
  end
end

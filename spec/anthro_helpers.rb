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

  def anthro_domain
    "anthro.collectionspace.org"
  end

  def anthro_cache
    cache_config = base_cache_config.merge({domain: anthro_domain})
    cache = CollectionSpace::Refcache.new(config: cache_config)
    populate(cache, cacheable_refnames(anthro_domain))
  end
  memo_wise(:anthro_cache)

  def anthro_csid_cache
    cache_config = base_cache_config.merge({domain: anthro_domain})
    cache = CollectionSpace::Refcache.new(config: cache_config)
    populate(cache, cacheable_csids)
  end
  memo_wise(:anthro_csid_cache)

  def anthro_combined_cache
    cache_config = base_cache_config.merge({domain: anthro_domain})
    cache = CollectionSpace::Refcache.new(config: cache_config)
    populate(cache, cacheable_refnames(anthro_domain), "refname")
    populate(cache, cacheable_csids, "csid")
  end
  memo_wise(:anthro_combined_cache)

  def anthro_co_1
    get_datahash(
      path: "spec/support/datahashes/anthro/collectionobject1.json"
    )
  end
end

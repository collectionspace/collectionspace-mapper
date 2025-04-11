# frozen_string_literal: true

module Helpers
  def lhmc_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: "https://lhmc.dev.collectionspace.org/cspace-services",
        username: "admin@lhmc.collectionspace.org",
        password: "Administrator"
      )
    )
  end
  memo_wise(:lhmc_client)

  def lhmc_domain
    "lhmc.collectionspace.org"
  end

  def lhmc_cache
    cache_config = base_cache_config.merge({domain: lhmc_domain})
    cache = CollectionSpace::Refcache.new(config: cache_config)
    populate(cache, cacheable_refnames(lhmc_domain))
  end
  memo_wise(:lhmc_cache)

  def lhmc_csid_cache
    cache_config = base_cache_config.merge({domain: lhmc_domain})
    cache = CollectionSpace::Refcache.new(config: cache_config)
    populate(cache, cacheable_csids)
  end
  memo_wise(:lhmc_csid_cache)
end

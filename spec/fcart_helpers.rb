# frozen_string_literal: true

module Helpers
  def fcart_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: "https://fcart.dev.collectionspace.org/cspace-services",
        username: "admin@fcart.collectionspace.org",
        password: "Administrator"
      )
    )
  end
  memo_wise(:fcart_client)

  def fcart_domain
    "fcart.collectionspace.org"
  end

  def fcart_cache
    cache_config = base_cache_config.merge({domain: fcart_domain})
    cache = CollectionSpace::Refcache.new(config: cache_config)
    populate(cache, cacheable_refnames(fcart_domain))
  end
  memo_wise(:fcart_cache)

  def fcart_csid_cache
    cache_config = base_cache_config.merge({domain: fcart_domain})
    cache = CollectionSpace::Refcache.new(config: cache_config)
    populate(cache, cacheable_csids)
  end
  memo_wise(:fcart_csid_cache)

  def fcart_combined_cache
    cache_config = base_cache_config.merge({domain: fcart_domain})
    cache = CollectionSpace::Refcache.new(config: cache_config)
    populate(cache, cacheable_refnames(fcart_domain), "refname")
    populate(cache, cacheable_csids, "csid")
  end
  memo_wise(:fcart_combined_cache)
end

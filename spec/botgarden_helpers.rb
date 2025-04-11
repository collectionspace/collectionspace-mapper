# frozen_string_literal: true

module Helpers
  def botgarden_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: "https://botgarden.dev.collectionspace.org/cspace-services",
        username: "admin@botgarden.collectionspace.org",
        password: "Administrator"
      )
    )
  end
  memo_wise(:botgarden_client)

  def botgarden_domain
    "botgarden.collectionspace.org"
  end

  def botgarden_cache
    cache_config = base_cache_config.merge({domain: botgarden_domain})
    cache = CollectionSpace::Refcache.new(config: cache_config)
    populate(cache, cacheable_refnames(botgarden_domain))
  end
  memo_wise(:botgarden_cache)

  def botgarden_csid_cache
    cache_config = base_cache_config.merge({domain: botgarden_domain})
    cache = CollectionSpace::Refcache.new(config: cache_config)
    populate(cache, cacheable_csids)
  end
  memo_wise(:botgarden_csid_cache)
end

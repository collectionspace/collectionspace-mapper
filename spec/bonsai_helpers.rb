# frozen_string_literal: true

module Helpers
  def bonsai_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: "https://bonsai.dev.collectionspace.org/cspace-services",
        username: "admin@bonsai.collectionspace.org",
        password: "Administrator"
      )
    )
  end
  memo_wise(:bonsai_client)

  def bonsai_domain
    "bonsai.collectionspace.org"
  end

  def bonsai_cache
    cache_config = base_cache_config.merge({domain: bonsai_domain})
    cache = CollectionSpace::Refcache.new(config: cache_config)
    populate(cache, cacheable_refnames(bonsai_domain))
  end
  memo_wise(:bonsai_cache)

  def bonsai_csid_cache
    cache_config = base_cache_config.merge({domain: bonsai_domain})
    cache = CollectionSpace::Refcache.new(config: cache_config)
    populate(cache, cacheable_csids)
  end
  memo_wise(:bonsai_csid_cache)
end

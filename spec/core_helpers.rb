# frozen_string_literal: true

require_relative "helpers"

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

  def core_domain
    "core.collectionspace.org"
  end

  def core_cache
    cache_config = base_cache_config.merge({domain: core_domain})
    cache = CollectionSpace::RefCache.new(config: cache_config)
    populate(cache, cacheable_refnames(core_domain))
  end
  memo_wise(:core_cache)

  def core_csid_cache
    cache_config = base_cache_config.merge({domain: core_domain})
    cache = CollectionSpace::RefCache.new(config: cache_config)
    populate(cache, cacheable_csids)
  end
  memo_wise(:core_csid_cache)
end

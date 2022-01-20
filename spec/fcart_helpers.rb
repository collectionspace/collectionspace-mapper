# frozen_string_literal: true

module Helpers
  def fcart_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'https://fcart.dev.collectionspace.org/cspace-services',
        username: 'admin@fcart.collectionspace.org',
        password: 'Administrator'
      )
    )
  end

  def fcart_cache
    cache_config = base_cache_config.merge({domain: 'fcart.collectionspace.org'})
    cache = CollectionSpace::RefCache.new(config: cache_config, client: fcart_client)
    populate_fcart(cache)
    cache
  end
  memo_wise(:fcart_cache)

  def populate_fcart(cache)
    terms = [
      ['personauthorities', 'person', 'Elizabeth',
       {refname: "urn:cspace:fcart.collectionspace.org:personauthorities:name(person):item:name(Elizabeth123)'Elizabeth'", csid: '1111-2222-3333-4444'}]    ]
    populate(cache, terms)
  end

end

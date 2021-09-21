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
      ['vocabularies', 'dateera', 'CE', "urn:cspace:fcart.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'"],
      ['personauthorities', 'person', 'Elizabeth',
       "urn:cspace:fcart.collectionspace.org:personauthorities:name(person):item:name(Elizabeth123)'Elizabeth'"]
   ]
    populate(cache, terms)
  end

  # this is a fake "client-specific" config based on the fcart profile.
  # for testing, we'll name it something else, make the customizations in the cache,
  #   and use fcart for other functionality
  def ba_cache
    cache_config = {
      domain: 'fcart.collectionspace.org',
      search_enabled: false,
      search_identifiers: false
    }
    CollectionSpace::RefCache.new(config: cache_config, client: fcart_client)
  end

  def populate_ba(cache)
    terms = [
      ['vocabularies', 'dateera', 'CE', "urn:cspace:fcart.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'"],
      ['vocabularies', 'datecertainty', 'supplied or inferred', "urn:cspace:fcart.collectionspace.org:vocabularies:name(datecertainty):item:name(suppliedorinferred1613499928079)'supplied or inferred'"],
      ['personauthorities', 'person', 'Elizabeth', "urn:cspace:fcart.collectionspace.org:personauthorities:name(person):item:name(Elizabeth123)'Elizabeth'"]
    ]
    populate(cache, terms)
  end
end

# frozen_string_literal: true

module Helpers
  def lhmc_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'https://lhmc.dev.collectionspace.org/cspace-services',
        username: 'admin@lhmc.collectionspace.org',
        password: 'Administrator'
      )
    )
  end

  def lhmc_cache
    cache_config = base_cache_config.merge({domain: 'lhmc.collectionspace.org'})
    cache = CollectionSpace::RefCache.new(config: cache_config, client: lhmc_client)
    populate_lhmc(cache)
    cache
  end
  memo_wise(:lhmc_cache)

  def populate_lhmc(cache)
    terms = [
      ['personauthorities', 'person', 'Ann Analyst',
       {refname: "urn:cspace:lhmc.collectionspace.org:personauthorities:name(person):item:name(AnnAnalyst1594848799340)'Ann Analyst'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'agerange', 'adolescent 26-75%',
       {refname: "urn:cspace:lhmc.collectionspace.org:vocabularies:name(agerange):item:name(adolescent_26_75)'adolescent 26-75%'", csid: '1111-2222-3333-4444'}]
    ]
    populate(cache, terms)
  end
end

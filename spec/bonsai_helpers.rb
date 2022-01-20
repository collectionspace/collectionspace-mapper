# frozen_string_literal: true

module Helpers
  def bonsai_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'https://bonsai.dev.collectionspace.org/cspace-services',
        username: 'admin@bonsai.collectionspace.org',
        password: 'Administrator'
      )
    )
  end

  def bonsai_cache
    cache_config = base_cache_config.merge({domain: 'bonsai.collectionspace.org'})
    cache = CollectionSpace::RefCache.new(config: cache_config, client: bonsai_client)
    populate_bonsai(cache)
    cache
  end
  memo_wise(:bonsai_cache)

  def populate_bonsai(cache)
    terms = [
      ['orgauthorities', 'organization', 'Bonsai Museum',
       {refname: "urn:cspace:bonsai.collectionspace.org:orgauthorities:name(organization):item:name(BonsaiMuseum1598919439027)'Bonsai Museum'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Bonsai Store',
       {refname: "urn:cspace:bonsai.collectionspace.org:orgauthorities:name(organization):item:name(BonsaiStore1598920297843)'Bonsai Store'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Ann Authorizer',
       {refname: "urn:cspace:bonsai.collectionspace.org:personauthorities:name(person):item:name(AnnAuthorizer1598919551068)'Ann Authorizer'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Debbie Depositor',
       {refname: "urn:cspace:bonsai.collectionspace.org:personauthorities:name(person):item:name(DebbieDepositor1598919493867)'Debbie Depositor'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Priscilla Plantsale',
       {refname: "urn:cspace:bonsai.collectionspace.org:personauthorities:name(person):item:name(PriscillaPlantsale1598920259864)'Priscilla Plantsale'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'currency', 'Canadian Dollar',
       {refname: "urn:cspace:bonsai.collectionspace.org:vocabularies:name(currency):item:name(CAD)'Canadian Dollar'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'dateera', 'CE',
       {refname: "urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'deaccessionapprovalgroup', 'collection committee',
       {refname: "urn:cspace:bonsai.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(collection_committee)'collection committee'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'deaccessionapprovalstatus', 'approved',
       {refname: "urn:cspace:bonsai.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(approved)'approved'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'deaccessionapprovalstatus', 'not required',
       {refname: "urn:cspace:bonsai.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(not_required)'not required'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'disposalmethod', 'public auction',
       {refname: "urn:cspace:bonsai.collectionspace.org:vocabularies:name(disposalmethod):item:name(public_auction)'public auction'", csid: '1111-2222-3333-4444'}],
    ]
    populate(cache, terms)
  end
end

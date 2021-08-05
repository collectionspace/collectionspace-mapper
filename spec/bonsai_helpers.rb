# frozen_string_literal: true

require 'memo_wise'

module Helpers
  prepend MemoWise
  extend self
  
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
    cache_config = {
      domain: 'bonsai.collectionspace.org'
    }
    cache = CollectionSpace::RefCache.new(config: cache_config, client: bonsai_client)
    populate_bonsai(cache)
    cache
  end
  memo_wise(:bonsai_cache)

  def populate_bonsai(cache)
    terms = [
      ['orgauthorities', 'organization', 'Bonsai Museum', "urn:cspace:bonsai.collectionspace.org:orgauthorities:name(organization):item:name(BonsaiMuseum1598919439027)'Bonsai Museum'"],
      ['orgauthorities', 'organization', 'Bonsai Store', "urn:cspace:bonsai.collectionspace.org:orgauthorities:name(organization):item:name(BonsaiStore1598920297843)'Bonsai Store'"],
      ['personauthorities', 'person', 'Ann Authorizer', "urn:cspace:bonsai.collectionspace.org:personauthorities:name(person):item:name(AnnAuthorizer1598919551068)'Ann Authorizer'"],
      ['personauthorities', 'person', 'Debbie Depositor', "urn:cspace:bonsai.collectionspace.org:personauthorities:name(person):item:name(DebbieDepositor1598919493867)'Debbie Depositor'"],
      ['personauthorities', 'person', 'Priscilla Plantsale', "urn:cspace:bonsai.collectionspace.org:personauthorities:name(person):item:name(PriscillaPlantsale1598920259864)'Priscilla Plantsale'"],
      ['vocabularies', 'currency', 'Canadian Dollar', "urn:cspace:bonsai.collectionspace.org:vocabularies:name(currency):item:name(CAD)'Canadian Dollar'"],
      ['vocabularies', 'dateera', 'CE', "urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'"],
      ['vocabularies', 'deaccessionapprovalgroup', 'collection committee', "urn:cspace:bonsai.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(collection_committee)'collection committee'"],
      ['vocabularies', 'deaccessionapprovalstatus', 'approved', "urn:cspace:bonsai.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(approved)'approved'"],
      ['vocabularies', 'deaccessionapprovalstatus', 'not required', "urn:cspace:bonsai.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(not_required)'not required'"],
      ['vocabularies', 'disposalmethod', 'public auction', "urn:cspace:bonsai.collectionspace.org:vocabularies:name(disposalmethod):item:name(public_auction)'public auction'"],
    ]
    populate(cache, terms)
  end
end

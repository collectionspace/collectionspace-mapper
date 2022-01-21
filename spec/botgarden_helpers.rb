# frozen_string_literal: true

module Helpers
  def botgarden_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'https://botgarden.dev.collectionspace.org/cspace-services',
        username: 'admin@botgarden.collectionspace.org',
        password: 'Administrator'
      )
    )
  end

  def botgarden_cache
    cache_config = base_cache_config.merge({domain: 'botgarden.collectionspace.org'})
    cache = CollectionSpace::RefCache.new(config: cache_config, client: botgarden_client)
    populate_botgarden(cache)
    cache
  end
  memo_wise(:botgarden_cache)

  def populate_botgarden(cache)
    terms = [
      ['citationauthorities', 'citation', 'FNA Volume 19',
       {refname: "urn:cspace:botgarden.collectionspace.org:citationauthorities:name(citation):item:name(FNAVolume191599238760383)'FNA Volume 19'", csid: '1111-2222-3333-4444'}],
      ['citationauthorities', 'citation', 'Sp. Pl. 2: 899. 1753',
       {refname: "urn:cspace:botgarden.collectionspace.org:citationauthorities:name(citation):item:name(SpPl289917531599238184211)'Sp. Pl. 2: 899. 1753'", csid: '1111-2222-3333-4444'}],
      ['citationauthorities', 'worldcat', 'Bull. Torrey Bot. Club',
       {refname: "urn:cspace:botgarden.collectionspace.org:citationauthorities:name(worldcat):item:name(BullTorreyBotClub331599245358364)'Bull. Torrey Bot. Club 33'", csid: '1111-2222-3333-4444'}],
      ['conceptauthorities', 'concept', 'Official',
       {refname: "urn:cspace:botgarden.collectionspace.org:conceptauthorities:name(concept):item:name(Official1599737276242)'Official'", csid: '1111-2222-3333-4444'}],
      ['locationauthorities', 'location', 'Corner',
       {refname: "urn:cspace:botgarden.collectionspace.org:locationauthorities:name(location):item:name(Corner1599737289184)'Corner'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'FVA',
       {refname: "urn:cspace:botgarden.collectionspace.org:orgauthorities:name(organization):item:name(FVA1599246022216)'FVA'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Linnaeus, Carl',
       {refname: "urn:cspace:botgarden.collectionspace.org:personauthorities:name(person):item:name(LinnaeusCarl1599238374086)'Linnaeus, Carl'", csid: '1111-2222-3333-4444'}],
      ['taxonomyauthority', 'taxon', 'Domestic',
       {refname: "urn:cspace:botgarden.collectionspace.org:taxonomyauthority:name(taxon):item:name(Domestic1599750187683)'Domestic'", csid: '1111-2222-3333-4444'}],
      ['taxonomyauthority', 'taxon', 'Tropez',
       {refname: "urn:cspace:botgarden.collectionspace.org:taxonomyauthority:name(taxon):item:name(Tropez1599750195530)'Tropez'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'cuttingtype', 'hardwood',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(cuttingtype):item:name(hardwood)'hardwood'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'dateera', 'CE',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'durationunit', 'Days',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(durationunit):item:name(days)'Days'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'durationunit', 'Hours',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(durationunit):item:name(hours)'Hours'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'languages', 'English',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(languages):item:name(eng)'English'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'languages', 'French',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(languages):item:name(fra)'French'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'languages', 'Latin',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(languages):item:name(lat)'Latin'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'potsize', '1 gal. pot',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(potsize):item:name(OneGalPot)'1 gal. pot'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'propActivityType', 'benlate and captan',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(propActivityType):item:name(benlateAndCaptan)'benlate and captan'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'propChemicals', 'benlate and physan',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(propChemicals):item:name(benlateAndPhysan)'benlate and physan'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'propConditions', 'glass cover',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(propConditions):item:name(glassCover)'glass cover'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'propHormones', 'hormone',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(propHormones):item:name(hormone)'hormone'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'propPlantType', 'bulbs',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(propPlantType):item:name(bulbs)'bulbs'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'propreason', 'conservation',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(propreason):item:name(conservation)'conservation'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'proptype', 'Division',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(proptype):item:name(division)'Division'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'scarstrat', 'boiling water',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(scarstrat):item:name(boilingwater)'boiling water'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'scarstrat', 'cold strat',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(scarstrat):item:name(coldstrat)'cold strat'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'taxontermflag', 'invalid',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(taxontermflag):item:name(invalid)'invalid'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'taxontermflag', 'valid',
       {refname: "urn:cspace:botgarden.collectionspace.org:vocabularies:name(taxontermflag):item:name(valid)'valid'", csid: '1111-2222-3333-4444'}]
    ]
    populate(cache, terms)
  end
end

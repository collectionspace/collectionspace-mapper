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
       "urn:cspace:botgarden.collectionspace.org:citationauthorities:name(citation):item:name(FNAVolume191599238760383)'FNA Volume 19'"],
      ['citationauthorities', 'citation', 'Sp. Pl. 2: 899. 1753',
       "urn:cspace:botgarden.collectionspace.org:citationauthorities:name(citation):item:name(SpPl289917531599238184211)'Sp. Pl. 2: 899. 1753'"],
      ['citationauthorities', 'worldcat', 'Bull. Torrey Bot. Club',
       "urn:cspace:botgarden.collectionspace.org:citationauthorities:name(worldcat):item:name(BullTorreyBotClub331599245358364)'Bull. Torrey Bot. Club 33'"],
      ['conceptauthorities', 'concept', 'Official',
       "urn:cspace:botgarden.collectionspace.org:conceptauthorities:name(concept):item:name(Official1599737276242)'Official'"],
      ['locationauthorities', 'location', 'Corner',
       "urn:cspace:botgarden.collectionspace.org:locationauthorities:name(location):item:name(Corner1599737289184)'Corner'"],
      ['orgauthorities', 'organization', 'FVA',
       "urn:cspace:botgarden.collectionspace.org:orgauthorities:name(organization):item:name(FVA1599246022216)'FVA'"],
      ['personauthorities', 'person', 'Linnaeus, Carl',
       "urn:cspace:botgarden.collectionspace.org:personauthorities:name(person):item:name(LinnaeusCarl1599238374086)'Linnaeus, Carl'"],
      ['taxonomyauthority', 'taxon', 'Domestic',
       "urn:cspace:botgarden.collectionspace.org:taxonomyauthority:name(taxon):item:name(Domestic1599750187683)'Domestic'"],
      ['taxonomyauthority', 'taxon', 'Tropez',
       "urn:cspace:botgarden.collectionspace.org:taxonomyauthority:name(taxon):item:name(Tropez1599750195530)'Tropez'"],
      ['vocabularies', 'cuttingtype', 'hardwood',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(cuttingtype):item:name(hardwood)'hardwood'"],
      ['vocabularies', 'dateera', 'CE',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'"],
      ['vocabularies', 'durationunit', 'Days',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(durationunit):item:name(days)'Days'"],
      ['vocabularies', 'durationunit', 'Hours',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(durationunit):item:name(hours)'Hours'"],
      ['vocabularies', 'languages', 'English',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(languages):item:name(eng)'English'"],
      ['vocabularies', 'languages', 'French',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(languages):item:name(fra)'French'"],
      ['vocabularies', 'languages', 'Latin',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(languages):item:name(lat)'Latin'"],
      ['vocabularies', 'potsize', '1 gal. pot',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(potsize):item:name(OneGalPot)'1 gal. pot'"],
      ['vocabularies', 'propActivityType', 'benlate and captan',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(propActivityType):item:name(benlateAndCaptan)'benlate and captan'"],
      ['vocabularies', 'propChemicals', 'benlate and physan',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(propChemicals):item:name(benlateAndPhysan)'benlate and physan'"],
      ['vocabularies', 'propConditions', 'glass cover',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(propConditions):item:name(glassCover)'glass cover'"],
      ['vocabularies', 'propHormones', 'hormone',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(propHormones):item:name(hormone)'hormone'"],
      ['vocabularies', 'propPlantType', 'bulbs',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(propPlantType):item:name(bulbs)'bulbs'"],
      ['vocabularies', 'propreason', 'conservation',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(propreason):item:name(conservation)'conservation'"],
      ['vocabularies', 'proptype', 'Division',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(proptype):item:name(division)'Division'"],
      ['vocabularies', 'scarstrat', 'boiling water',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(scarstrat):item:name(boilingwater)'boiling water'"],
      ['vocabularies', 'scarstrat', 'cold strat',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(scarstrat):item:name(coldstrat)'cold strat'"],
      ['vocabularies', 'taxontermflag', 'invalid',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(taxontermflag):item:name(invalid)'invalid'"],
      ['vocabularies', 'taxontermflag', 'valid',
       "urn:cspace:botgarden.collectionspace.org:vocabularies:name(taxontermflag):item:name(valid)'valid'"],
    ]
    populate(cache, terms)
  end
end

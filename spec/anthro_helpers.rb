# frozen_string_literal: true

module Helpers
  def anthro_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'https://anthro.dev.collectionspace.org/cspace-services',
        username: 'admin@anthro.collectionspace.org',
        password: 'Administrator'
      )
    )
  end
  
  def anthro_cache
    cache_config = {
      domain: 'anthro.collectionspace.org',
      search_enabled: true,
      search_identifiers: false
    }
    CollectionSpace::RefCache.new(config: cache_config, client: anthro_client)
  end

  def populate_anthro(cache)
    terms = [
      ['personauthorities', 'person', 'Ann Analyst', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(AnnAnalyst1594848799340)'Ann Analyst'"],
      ['personauthorities', 'person', 'Gabriel Solares', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(GabrielSolares1594848906847)'Gabriel Solares'"],
      ['conceptauthorities', 'archculture', 'Blackfoot', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(archculture):item:name(Blackfoot1576172504869)'Blackfoot'"],
      ['conceptauthorities', 'concept', 'Birds', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(concept):item:name(Birds918181)'Birds'"],
      ['conceptauthorities', 'ethculture', 'Batak', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(ethculture):item:name(Batak1576172496916)'Batak'"],
      ['conceptauthorities', 'material_ca', 'Feathers', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(material_ca):item:name(Feathers918181)'Feathers'"],
      ['placeauthorities', 'place', 'York County, Pennsylvania', "urn:cspace:anthro.collectionspace.org:placeauthorities:name(place):item:name(YorkCountyPennsylvania)'York County, Pennsylvania'"],
      ['vocabularies', 'agerange', 'adolescent 26-75%', "urn:cspace:anthro.collectionspace.org:vocabularies:name(agerange):item:name(adolescent_26_75)'adolescent 26-75%'"],
      ['vocabularies', 'agerange', 'adult 0-25%', "urn:cspace:anthro.collectionspace.org:vocabularies:name(agerange):item:name(adult_0_25)'adult 0-25%'"],
      ['vocabularies', 'behrensmeyer', '2 - longitudinal cracks, exfoliation on surface', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(2)'2 - longitudinal cracks, exfoliation on surface'"], 
      ['vocabularies', 'behrensmeyer', '5 - bone crumbling in situ, large splinters', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(5)'5 - bone crumbling in situ, large splinters'"],
      ['vocabularies', 'behrensmeyer', '1 - longitudinal and/or mosaic cracking present on surface', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(1)'1 - longitudinal and/or mosaic cracking present on surface'"], 
      ['vocabularies', 'behrensmeyer', '3 - fibrous texture, extensive exfoliation', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(3)'3 - fibrous texture, extensive exfoliation'"],
      ['vocabularies', 'bodyside', 'midline', "urn:cspace:anthro.collectionspace.org:vocabularies:name(bodyside):item:name(midline)'midline'"],
      ['vocabularies', 'mortuarytreatment', 'burned/unburned bone mixture', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(burnedunburnedbonemixture)'burned/unburned bone mixture'"],
      ['vocabularies', 'mortuarytreatment', 'embalmed', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(enbalmed)'enbalmed"],
      ['vocabularies', 'mortuarytreatment', 'excarnated', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(excarnated)'excarnated'"],
      ['vocabularies', 'mortuarytreatment', 'mummified', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(mummified)'mummified'"],
      ['vocabularies', 'annotationtype', 'image made', "urn:cspace:anthro.collectionspace.org:vocabularies:name(annotationtype):item:name(image_made)'image made'"],
      ['vocabularies', 'annotationtype', 'type', "urn:cspace:anthro.collectionspace.org:vocabularies:name(annotationtype):item:name(type)'type'"],
      ['vocabularies', 'dateera', 'CE', "urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'"],
      ['vocabularies', 'inventorystatus', 'unknown', "urn:cspace:anthro.collectionspace.org:vocabularies:name(inventorystatus):item:name(unknown)'unknown'"],
      ['vocabularies', 'nagpracategory', 'not subject to NAGPRA', "urn:cspace:anthro.collectionspace.org:vocabularies:name(nagpracategory):item:name(nonNagpra)'not subject to NAGPRA'"],
      ['vocabularies', 'nagpracategory', 'subject to NAGPRA (unspec.)', "urn:cspace:anthro.collectionspace.org:vocabularies:name(nagpracategory):item:name(subjectToNAGPRA)'subject to NAGPRA (unspec.)'"],
      ['vocabularies', 'prodpeoplerole', 'designed after', "urn:cspace:anthro.collectionspace.org:vocabularies:name(prodpeoplerole):item:name(designedAfter)'designed after'"],
      ['vocabularies', 'prodpeoplerole', 'traditional makers', "urn:cspace:anthro.collectionspace.org:vocabularies:name(prodpeoplerole):item:name(traditionalMakers)'traditional makers'"],
      ['vocabularies', 'publishto', 'DPLA', "urn:cspace:anthro.collectionspace.org:vocabularies:name(publishto):item:name(dpla)'DPLA'"],
      ['vocabularies', 'publishto', 'Omeka', "urn:cspace:anthro.collectionspace.org:vocabularies:name(publishto):item:name(omeka)'Omeka'"],
    ]
    populate(cache, terms)
  end

  def anthro_co_1
    get_datahash(path: 'spec/fixtures/files/datahashes/anthro/collectionobject1.json')
  end
end
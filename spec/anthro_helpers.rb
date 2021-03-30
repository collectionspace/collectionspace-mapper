# frozen_string_literal: true

module Helpers
  extend self
  
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
      search_enabled: false,
      search_identifiers: false
    }
    CollectionSpace::RefCache.new(config: cache_config, client: anthro_client)
  end

  def anthro_object_mapper
    path = 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4_1_2-collectionobject.json'
    get_record_mapper_object(path)
  end
  
  def populate_anthro(cache)
    terms = [
      ['conceptauthorities', 'archculture', 'Blackfoot', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(archculture):item:name(Blackfoot1576172504869)'Blackfoot'"],
      ['conceptauthorities', 'concept', 'Birds', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(concept):item:name(Birds918181)'Birds'"],
      ['conceptauthorities', 'ethculture', 'Batak', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(ethculture):item:name(Batak1576172496916)'Batak'"],
      ['conceptauthorities', 'ethculture', 'Got', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(ethculture):item:name(Got1599824429903)'Got'"],
      ['conceptauthorities', 'ethculture', 'Hero', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(ethculture):item:name(Hero1599824418804)'Hero'"],
      ['conceptauthorities', 'material_ca', 'Feathers', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(material_ca):item:name(Feathers918181)'Feathers'"],
      ['orgauthorities', 'organization', 'Hola', "urn:cspace:anthro.collectionspace.org:orgauthorities:name(organization):item:name(Hola1599824351945)'Hola'"],
      ['orgauthorities', 'organization', 'Organization 1', "urn:cspace:anthro.collectionspace.org:orgauthorities:name(organization):item:name(Organization11587136583004)'Organization 1'"],
      ['orgauthorities', 'organization', 'chores', "urn:cspace:anthro.collectionspace.org:orgauthorities:name(organization):item:name(chores1599824370125)'chores'"],
      ['personauthorities', 'person', 'Ann Analyst', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(AnnAnalyst1594848799340)'Ann Analyst'"],
      ['personauthorities', 'person', 'Gabriel Solares', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(GabrielSolares1594848906847)'Gabriel Solares'"],
      ['personauthorities', 'person', 'Tegla', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(Tegla1599824325923)'Tegla'"],
      ['personauthorities', 'person', 'Tom', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(Tom1599824331955)'Tom'"],
      ['placeauthorities', 'place', 'Early', "urn:cspace:anthro.collectionspace.org:placeauthorities:name(place):item:name(Early1599824413345)'Early'"],
      ['placeauthorities', 'place', 'Local', "urn:cspace:anthro.collectionspace.org:placeauthorities:name(place):item:name(Local1599824385298)'Local'"],
      ['placeauthorities', 'place', 'York County, Pennsylvania', "urn:cspace:anthro.collectionspace.org:placeauthorities:name(place):item:name(YorkCountyPennsylvania)'York County, Pennsylvania'"],
      ['vocabularies', 'agerange', 'adolescent 26-75%', "urn:cspace:anthro.collectionspace.org:vocabularies:name(agerange):item:name(adolescent_26_75)'adolescent 26-75%'"],
      ['vocabularies', 'agerange', 'adult 0-25%', "urn:cspace:anthro.collectionspace.org:vocabularies:name(agerange):item:name(adult_0_25)'adult 0-25%'"],
      ['vocabularies', 'annotationtype', 'image made', "urn:cspace:anthro.collectionspace.org:vocabularies:name(annotationtype):item:name(image_made)'image made'"],
      ['vocabularies', 'annotationtype', 'type', "urn:cspace:anthro.collectionspace.org:vocabularies:name(annotationtype):item:name(type)'type'"],
      ['vocabularies', 'behrensmeyer', '0 - no cracking or flaking on bone surface', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(0)'0 - no cracking or flaking on bone surface'"], 
      ['vocabularies', 'behrensmeyer', '1 - longitudinal and/or mosaic cracking present on surface', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(1)'1 - longitudinal and/or mosaic cracking present on surface'"], 
      ['vocabularies', 'behrensmeyer', '2 - longitudinal cracks, exfoliation on surface', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(2)'2 - longitudinal cracks, exfoliation on surface'"], 
      ['vocabularies', 'behrensmeyer', '3 - fibrous texture, extensive exfoliation', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(3)'3 - fibrous texture, extensive exfoliation'"],
      ['vocabularies', 'behrensmeyer', '5 - bone crumbling in situ, large splinters', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(5)'5 - bone crumbling in situ, large splinters'"],
      ['vocabularies', 'bodyside', 'midline', "urn:cspace:anthro.collectionspace.org:vocabularies:name(bodyside):item:name(midline)'midline'"],
      ['vocabularies', 'dateera', 'CE', "urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'"],
      ['vocabularies', 'inventorystatus', 'accessioned', "urn:cspace:anthro.collectionspace.org:vocabularies:name(inventorystatus):item:name(accessioned)'accessioned'"],
      ['vocabularies', 'inventorystatus', 'unknown', "urn:cspace:anthro.collectionspace.org:vocabularies:name(inventorystatus):item:name(unknown)'unknown'"],
      ['vocabularies', 'languages', 'Chinese', "urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(zho)'Chinese'"],
      ['vocabularies', 'languages', 'English', "urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(eng)'English'"],
      ['vocabularies', 'languages', 'French', "urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(fra)'French'"],
      ['vocabularies', 'languages', 'German', "urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(deu)'German'"],
      ['vocabularies', 'languages', 'Spanish', "urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(spa)'Spanish'"],
      ['vocabularies', 'limitationlevel', 'recommendation', "urn:cspace:anthro.collectionspace.org:vocabularies:name(limitationlevel):item:name(recommendation)'recommendation'"],
      ['vocabularies', 'limitationlevel', 'restriction', "urn:cspace:anthro.collectionspace.org:vocabularies:name(limitationlevel):item:name(restriction)'restriction'"],
      ['vocabularies', 'limitationtype', 'lending', "urn:cspace:anthro.collectionspace.org:vocabularies:name(limitationtype):item:name(lending)'lending'"],
      ['vocabularies', 'limitationtype', 'publication', "urn:cspace:anthro.collectionspace.org:vocabularies:name(limitationtype):item:name(publication)'publication'"],
      ['vocabularies', 'mortuarytreatment', 'burned/unburned bone mixture', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(burnedunburnedbonemixture)'burned/unburned bone mixture'"],
      ['vocabularies', 'mortuarytreatment', 'enbalmed', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(enbalmed)'enbalmed'"],
      ['vocabularies', 'mortuarytreatment', 'excarnated', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(excarnated)'excarnated'"],
      ['vocabularies', 'mortuarytreatment', 'mummified', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(mummified)'mummified'"],
      ['vocabularies', 'nagpracategory', 'not subject to NAGPRA', "urn:cspace:anthro.collectionspace.org:vocabularies:name(nagpracategory):item:name(nonNagpra)'not subject to NAGPRA'"],
      ['vocabularies', 'nagpracategory', 'subject to NAGPRA (unspec.)', "urn:cspace:anthro.collectionspace.org:vocabularies:name(nagpracategory):item:name(subjectToNAGPRA)'subject to NAGPRA (unspec.)'"],
      ['vocabularies', 'nagpraclaimtype', 'affiliated human skeletal remains (HSR)', "urn:cspace:anthro.collectionspace.org:vocabularies:name(nagpraclaimtype):item:name(affiliatedHsr)'affiliated human skeletal remains (HSR)'"],
      ['vocabularies', 'nagpraclaimtype', 'needs further research', "urn:cspace:anthro.collectionspace.org:vocabularies:name(nagpraclaimtype):item:name(needsFurtherResearch)'needs further research'"],
      ['vocabularies', 'nagpraclaimtype', 'not subject to NAGPRA', "urn:cspace:anthro.collectionspace.org:vocabularies:name(nagpraclaimtype):item:name(nonNagpra)'not subject to NAGPRA'"],
      ['vocabularies', 'nagpraclaimtype', 'object of cultural patrimony', "urn:cspace:anthro.collectionspace.org:vocabularies:name(nagpraclaimtype):item:name(objectOfCulturalPatrimony)'object of cultural patrimony'"],
      ['vocabularies', 'nagpraclaimtype', 'unassociated funerary object (UFO)', "urn:cspace:anthro.collectionspace.org:vocabularies:name(nagpraclaimtype):item:name(ufo)'unassociated funerary object (UFO)'"],
      ['vocabularies', 'prodpeoplerole', 'designed after', "urn:cspace:anthro.collectionspace.org:vocabularies:name(prodpeoplerole):item:name(designedAfter)'designed after'"],
      ['vocabularies', 'prodpeoplerole', 'traditional makers', "urn:cspace:anthro.collectionspace.org:vocabularies:name(prodpeoplerole):item:name(traditionalMakers)'traditional makers'"],
      ['vocabularies', 'publishto', 'DPLA', "urn:cspace:anthro.collectionspace.org:vocabularies:name(publishto):item:name(dpla)'DPLA'"],
      ['vocabularies', 'publishto', 'Omeka', "urn:cspace:anthro.collectionspace.org:vocabularies:name(publishto):item:name(omeka)'Omeka'"],
      ['vocabularies', 'cranialdeformationcategory', 'other (describe)', "urn:cspace:anthro.collectionspace.org:vocabularies:name(cranialdeformationcategory):item:name(other)'other (describe)'"],
      ['vocabularies', 'cranialdeformationcategory', 'tabular', "urn:cspace:anthro.collectionspace.org:vocabularies:name(cranialdeformationcategory):item:name(tabular)'tabular'"],
      ['vocabularies', 'cranialdeformationcategory', 'circumferential', "urn:cspace:anthro.collectionspace.org:vocabularies:name(cranialdeformationcategory):item:name(circumferential)'circumferential'"],
      ['vocabularies', 'trepanationcertainty', 'possible trepanation', "urn:cspace:anthro.collectionspace.org:vocabularies:name(trepanationcertainty):item:name(possible)'possible trepanation'"],
      ['vocabularies', 'trepanationcertainty', 'clear evidence of trepanation', "urn:cspace:anthro.collectionspace.org:vocabularies:name(trepanationcertainty):item:name(clear)'clear evidence of trepanation'"],
      ['vocabularies', 'trepanationtechnique', 'grooving', "urn:cspace:anthro.collectionspace.org:vocabularies:name(trepanationtechnique):item:name(grooving)'grooving'"],
      ['vocabularies', 'trepanationtechnique', 'grooving', "urn:cspace:anthro.collectionspace.org:vocabularies:name(trepanationtechnique):item:name(grooving)'grooving'"],
      ['vocabularies', 'trepanationhealing', 'possible healing', "urn:cspace:anthro.collectionspace.org:vocabularies:name(trepanationhealing):item:name(possible)'possible healing'"],
      ['vocabularies', 'trepanationhealing', 'no healing', "urn:cspace:anthro.collectionspace.org:vocabularies:name(trepanationhealing):item:name(none)'no healing'"],
      ['vocabularies', 'trepanationhealing', 'definite evidence for healing', "urn:cspace:anthro.collectionspace.org:vocabularies:name(trepanationhealing):item:name(definite)'definite evidence for healing'"],
      ['vocabularies', 'mortuarytreatment', 'excarnated', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(excarnated)'excarnated'"],
      ['vocabularies', 'behrensmeyer', '3 - fibrous texture, extensive exfoliation', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(3)'3 - fibrous texture, extensive exfoliation'"],
      ['vocabularies', 'dateera', 'CE', "urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'"],
      ['vocabularies', 'dateera', 'CE', "urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'"],
      ['vocabularies', 'dateera', 'CE', "urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'"],
      ['vocabularies', 'dateera', 'CE', "urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'"],
      ['vocabularies', 'osteocompleteness', 'mandible only', "urn:cspace:anthro.collectionspace.org:vocabularies:name(osteocompleteness):item:name(mandible)'mandible only'"],
      ['vocabularies', 'behrensmeyer', '4 - coarsely fibrous texture, splinters of bone loose on the surface, open cracks', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(4)'4 - coarsely fibrous texture, splinters of bone loose on the surface, open cracks'"],
      ['vocabularies', 'dentitionscore', 'not applicable', "urn:cspace:anthro.collectionspace.org:vocabularies:name(dentitionscore):item:name(notapplicable)'not applicable'"],
      ['personauthorities', 'person', 'sniper', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(sniper1599821165616)'sniper'"],
      ['personauthorities', 'person', 'fullclip', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(fullclip1599821193344)'fullclip'"],
      ['personauthorities', 'person', 'fullclip', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(fullclip1599821140041)'fullclip'"],
      ['personauthorities', 'person', 'praya', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(praya1599821095120)'praya'"],
      ['personauthorities', 'person', 'jijoe', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(jijoe1599821246989)'jijoe'"],
    ]
    populate(cache, terms)
  end

  def anthro_co_1
    get_datahash(path: 'spec/fixtures/files/datahashes/anthro/collectionobject1.json')
  end
end

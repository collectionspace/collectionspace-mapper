# frozen_string_literal: true

require 'memo_wise'

module Helpers
  prepend MemoWise
  extend self

  def core_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'https://core.dev.collectionspace.org/cspace-services',
        username: 'admin@core.collectionspace.org',
        password: 'Administrator'
      )
    )
  end
    
  def core_cache
    cache_config = {
      domain: 'core.collectionspace.org',
      search_enabled: true,
      search_identifiers: false
    }
    cache = CollectionSpace::RefCache.new(config: cache_config, client: core_client)
    populate_core(cache)
    cache
  end
  memo_wise(:core_cache)

  def core_cache_search
    cache_config = {
      domain: 'core.collectionspace.org',
      search_enabled: true,
      search_identifiers: false
    }
    cache = CollectionSpace::RefCache.new(config: cache_config, client: core_client)
    populate_core(cache)
    cache
  end

  def core_object_mapper
    path = 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_collectionobject.json'
    get_record_mapper_object(path)
  end

  def populate_core(cache)
    terms = [
      ['citationauthorities', 'citation', 'Arthur', "urn:cspace:core.collectionspace.org:citationauthorities:name(citation):item:name(Arthur62605812848)'Arthur'"],      
      ['citationauthorities', 'citation', 'Harding', "urn:cspace:core.collectionspace.org:citationauthorities:name(citation):item:name(Harding2510592089)'Harding'"],      
      ['citationauthorities', 'citation', 'Wanting', "urn:cspace:core.collectionspace.org:citationauthorities:name(citation):item:name(Wanting1599560009399)'Wanting'"],
      ['citationauthorities', 'citation', 'makasi', "urn:cspace:core.collectionspace.org:citationauthorities:name(citation):item:name(makasi1599645537547)'makasi'"],
      ['citationauthorities', 'worldcat', 'Chelse', "urn:cspace:core.collectionspace.org:citationauthorities:name(worldcat):item:name(Chelse1599645525740)'Chelse'"],
      ['citationauthorities', 'worldcat', 'Patiently', "urn:cspace:core.collectionspace.org:citationauthorities:name(worldcat):item:name(Patiently1599559993332)'Patiently'"],
      ['conceptauthorities', 'concept', 'Test', "urn:cspace:core.collectionspace.org:conceptauthorities:name(concept):item:name(Test1599650854716)'Test'"],
      ['conceptauthorities', 'concept', 'Uno', "urn:cspace:core.collectionspace.org:conceptauthorities:name(concept):item:name(Uno1599645111177)'Uno'"],
      ['conceptauthorities', 'occasion', 'Computer', "urn:cspace:core.collectionspace.org:conceptauthorities:name(occasion):item:name(Computer1599734104251)'Computer'"],
      ['locationauthorities', 'indeterminate', '~Indeterminate Location~', "urn:cspace:indeterminate:locationauthorities:name(indeterminate):item:name(indeterminate)'~Indeterminate Location~'"],
      ['locationauthorities', 'location', 'Abardares', "urn:cspace:core.collectionspace.org:locationauthorities:name(location):item:name(Abardares1599557570049)'Abardares'"],
      ['locationauthorities', 'location', 'Kalif', "urn:cspace:core.collectionspace.org:locationauthorities:name(location):item:name(Kalif1599734233745)'Kalif'"],
      ['locationauthorities', 'location', 'Khago', "urn:cspace:core.collectionspace.org:locationauthorities:name(location):item:name(Khago1599559772718)'Khago'"],
      ['locationauthorities', 'location', 'Stay', "urn:cspace:core.collectionspace.org:locationauthorities:name(offsite_sla):item:name(Stay1599559824865)'Stay'"],
      ['locationauthorities', 'offsite_sla', 'Lavington', "urn:cspace:core.collectionspace.org:locationauthorities:name(offsite_sla):item:name(Lavington1599144699983)'Lavington'"],
      ['locationauthorities', 'offsite_sla', 'Ngong', "urn:cspace:core.collectionspace.org:locationauthorities:name(offsite_sla):item:name(Ngong1599557586466)'Ngong'"],
      ['locationauthorities', 'offsite_sla', 'Stay', "urn:cspace:core.collectionspace.org:locationauthorities:name(offsite_sla):item:name(Stay)'Stay'"],
      ['orgauthorities', 'organization', '2021', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(20211599147173971)'2021'"],
      ['orgauthorities', 'organization', 'Astroworld', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Astroworld1599650794829)'Astroworld'"],
      ['orgauthorities', 'organization', 'Broker', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Broker1599221487572)'Broker'"],
      ['orgauthorities', 'organization', 'But Ohh', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(ButOhh1599665031368)'But Ohh'"],
      ['orgauthorities', 'organization', 'Cuckoo', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Cuckoo1599463786824)'Cuckoo'"],
      ['orgauthorities', 'organization', 'Ibiza', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Ibiza1599650806827)'Ibiza'"],
      ['orgauthorities', 'organization', 'Joseph Hills', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(JosephHills1599463935463)'Joseph Hills'"],
      ['orgauthorities', 'organization', 'Kremling', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Kremling1599464161204)'Kremling'"],
      ['orgauthorities', 'organization', 'MMG', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(MMG1599569514486)'MMG'"],
      ['orgauthorities', 'organization', 'Martin', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Martin1599559712783)'Martin'"],
      ['orgauthorities', 'organization', 'Ninja', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Ninja1599147339325)'Ninja'"],
      ['orgauthorities', 'organization', 'Oval', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Oval1599650891221)'Oval'"],
      ['orgauthorities', 'organization', 'Podoa', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Podoa1599645346399)'Podoa'"],
      ['orgauthorities', 'organization', 'Rock Nation', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(RockNation1599569481908)'Rock Nation'"],
      ['orgauthorities', 'organization', 'Sidarec', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Sidarec1599210955079)'Sidarec'"],
      ['orgauthorities', 'organization', 'TIm Herod', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(TImHerod1599144655199)'TIm Herod'"],
      ['orgauthorities', 'organization', 'Tasia', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Tasia1599734050597)'Tasia'"],
      ['orgauthorities', 'organization', 'Tesla', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Tesla1599144565539)'Tesla'"],
      ['orgauthorities', 'organization', 'Walai', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Walai1599645181370)'Walai'"],
      ['orgauthorities', 'organization', 'breakup', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(breakup1599559909048)'breakup'"],
      ['orgauthorities', 'organization', 'fggf', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(fggf1599552009173)'fggf'"],
      ['orgauthorities', 'organization', 'pandemic', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(pandemic1599645036126)'pandemic'"],
      ['orgauthorities', 'organization', 'pop', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(pop1599664789385)'pop'"],
      ['orgauthorities', 'organization', 'pupu', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(pupu1599645415676)'pupu'"],
      ['orgauthorities', 'organization', 'tent', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(tent1599664807586)'tent'"],
      ['orgauthorities', 'ulan_oa', 'Again', "urn:cspace:core.collectionspace.org:orgauthorities:name(ulan_oa):item:name(Again1599559881266)'Again'"],
      ['orgauthorities', 'ulan_oa', 'Signal', "urn:cspace:core.collectionspace.org:orgauthorities:name(ulan_oa):item:name(Signal1599559737158)'Signal'"],
      ['orgauthorities', 'ulan_oa', 'Very fats', "urn:cspace:core.collectionspace.org:orgauthorities:name(ulan_oa):item:name(Veryfats1599645188567)'Very fats'"],
      ['personauthorities', 'person',  'Broooks', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Broooks1599221558583)'Broooks'"],
      ['personauthorities', 'person', '2020', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(20201599147149106)'2020'"],
      ['personauthorities', 'person', '254Glock', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(254Glock1599569494651)'254Glock'"],
      ['personauthorities', 'person', 'Abel', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Abel1599464025893)'Abel'"],
      ['personauthorities', 'person', 'Alexa', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Alexa1599557607978)'Alexa'"],
      ['personauthorities', 'person', 'Andrew Watts', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(AndrewWatts1599144553996)'Andrew Watts'"],
      ['personauthorities', 'person', 'Busy', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Busy1599559723432)'Busy'"],
      ['personauthorities', 'person', 'Cardi', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Cardi1599569468209)'Cardi'"],
      ['personauthorities', 'person', 'Clemo', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Clemo1599221473000)'Clemo'"],
      ['personauthorities', 'person', 'Clon', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Clon1599569543362)'Clon'"],
      ['personauthorities', 'person', 'Comodore', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Comodore1599463826401)'Comodore'"],
      ['personauthorities', 'person', 'Comrade', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Comrade1599664745661)'Comrade'"],
      ['personauthorities', 'person', 'Cooper Phil', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(CooperPhil1599144599479)'Cooper Phil'"],
      ['personauthorities', 'person', 'Disturb', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Disturb1599665062738)'Disturb'"],
      ['personauthorities', 'person', 'Dudu', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Dudu1599645410044)'Dudu'"],
      ['personauthorities', 'person', 'Erick', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Erick1599734121151)'Erick'"],
      ['personauthorities', 'person', 'First Layer', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(FirstLayer1599463905818)'First Layer'"],
      ['personauthorities', 'person', 'Glock', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Glock1599580905730)'Glock'"],
      ['personauthorities', 'person', 'Gomongo', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Gomongo1599463746195)'Gomongo'"],
      ['personauthorities', 'person', 'Grace', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Grace1599569599918)'Grace'"],
      ['personauthorities', 'person', 'Henry', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Henry1599210937770)'Henry'"],
      ['personauthorities', 'person', 'Home Alone', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(HomeAlone1599144524188)'Home Alone'"],
      ['personauthorities', 'person', 'James', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(James1599210943727)'James'"],
      ['personauthorities', 'person', 'Jamo', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Jamo1599221465693)'Jamo'"],
      ['personauthorities', 'person', 'Joel', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Joel1599557736045)'Joel'"],
      ['personauthorities', 'person', 'John Allen', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(JohnAllen1599144390263)'John Allen'"],
      ['personauthorities', 'person', 'John Kay', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(JohnKay1599210868122)'John Kay'"],
      ['personauthorities', 'person', 'Kali', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kali1599221504661)'Kali'"],
      ['personauthorities', 'person', 'Karanja', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Karanja1599211015378)'Karanja'"],
      ['personauthorities', 'person', 'Kev', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kev1599058769862)'Kev'"],
      ['personauthorities', 'person', 'Kimani', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kimani1599210926973)'Kimani'"],
      ['personauthorities', 'person', 'Kimonda', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kimonda1599211004900)'Kimonda'"],
      ['personauthorities', 'person', 'King Kosa', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(KingKosa1599569726990)'King Kosa'"],
      ['personauthorities', 'person', 'Kinuthia', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kinuthia1599734017515)'Kinuthia'"],
      ['personauthorities', 'person', 'Lebron', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Lebron1599557725925)'Lebron'"],
      ['personauthorities', 'person', 'Lima', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Lima1599645323459)'Lima'"],
      ['personauthorities', 'person', 'Loan', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Loan1599210896616)'Loan'"],
      ['personauthorities', 'person', 'Mark Smith', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(MarkSmith)'Mark Smith'"],
      ['personauthorities', 'person', 'Meghan', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Meghan1599569567326)'Meghan'"],
      ['personauthorities', 'person', 'Nyauma', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Nyauma1599210983879)'Nyauma'"],
      ['personauthorities', 'person', 'Scribe', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Scribe1599645240974)'Scribe'"],
      ['personauthorities', 'person', 'Shen Yeng', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(ShenYeng1599569685887)'Shen Yeng'"],
      ['personauthorities', 'person', 'Soi', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Soi1599734190999)'Soi'"],
      ['personauthorities', 'person', 'Switch', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Switch1599645085995)'Switch'"],
      ['personauthorities', 'person', 'Tim Joes', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(TimJoes1599144424859)'Tim Joes'"],
      ['personauthorities', 'person', 'Trepoz', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Trepoz1599221497512)'Trepoz'"],
      ['personauthorities', 'person', 'Trevor', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Trevor1599144536281)'Trevor'"],
      ['personauthorities', 'person', 'Troy', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Troy1599144360617)'Troy'"],
      ['personauthorities', 'person', 'afa', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(afa1599645004939)'afa'"],
      ['personauthorities', 'person', 'cxcx', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(cxcx1599551790384)'cxcx'"],
      ['personauthorities', 'person', 'dfdd', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(dfdd1599551799173)'dfdd'"],
      ['personauthorities', 'person', 'dssd', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(dssd1599552004115)'dssd'"],
      ['personauthorities', 'person', 'fgfgf', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(fgfgf1599551987166)'fgfgf'"],
      ['personauthorities', 'person', 'giri', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(giri1599645613143)'giri'"],
      ['personauthorities', 'person', 'high grade', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(highgrade1599645597889)'high grade'"],
      ['personauthorities', 'person', 'malik', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(malik1599664876144)'malik'"],
      ['personauthorities', 'person', 'marcus', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(marcus1599650918612)'marcus'"],
      ['personauthorities', 'person', 'marley', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(marley1599650874712)'marley'"],
      ['personauthorities', 'person', 'rights', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(rights1599650868011)'rights'"],
      ['personauthorities', 'person', 'rudelyt', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(rudelyt1599664917218)'rudelyt'"],
      ['personauthorities', 'person', 'sasa', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(sasa1599551852678)'sasa'"],
      ['personauthorities', 'person', 'tint', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(tint1599664800144)'tint'"],
      ['personauthorities', 'person', 'tonight', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(tonight1599664781376)'tonight'"],
      ['personauthorities', 'ulan_pa', 'Chrus', "urn:cspace:core.collectionspace.org:personauthorities:name(ulan_pa):item:name(Chrus1599559702930)'Chrus'"],
      ['personauthorities', 'ulan_pa', 'We go', "urn:cspace:core.collectionspace.org:personauthorities:name(ulan_pa):item:name(Wego1599559866517)'We go'"],
      ['personauthorities', 'ulan_pa', 'panda nayo', "urn:cspace:core.collectionspace.org:personauthorities:name(ulan_pa):item:name(pandanayo1599645094507)'panda nayo'"],
      ['placeauthorities', 'place', 'Chillspot', "urn:cspace:core.collectionspace.org:placeauthorities:name(place):item:name(Chillspot1599145441945)'Chillspot'"],
      ['placeauthorities', 'tgn_place', 'mzingga', "urn:cspace:core.collectionspace.org:placeauthorities:name(tgn_place):item:name(mzingga1599645587502)'mzingga'"],
      ['vocabularies', 'agequalifier', 'older than', "urn:cspace:core.collectionspace.org:vocabularies:name(agequalifier):item:name(olderthan)'older than'"],
      ['vocabularies', 'collectionmethod', 'donation', "urn:cspace:core.collectionspace.org:vocabularies:name(collectionmethod):item:name(donation)'donation'"],
      ['vocabularies', 'collectionmethod', 'excavation', "urn:cspace:core.collectionspace.org:vocabularies:name(collectionmethod):item:name(excavation)'excavation'"],
      ['vocabularies', 'conditioncheckmethod', 'Observed', "urn:cspace:core.collectionspace.org:vocabularies:name(conditioncheckmethod):item:name(observed)'Observed'"],
      ['vocabularies', 'conditioncheckreason', 'Damaged in transit', "urn:cspace:core.collectionspace.org:vocabularies:name(conditioncheckreason):item:name(damagedintransit)'Damaged in transit'"],
      ['vocabularies', 'conditionfitness', 'Reasonable', "urn:cspace:core.collectionspace.org:vocabularies:name(conditionfitness):item:name(reasonable)'Reasonable'"],
      ['vocabularies', 'conservationstatus', 'Analysis complete', "urn:cspace:core.collectionspace.org:vocabularies:name(conservationstatus):item:name(analysiscomplete)'Analysis complete'"],
      ['vocabularies', 'conservationstatus', 'Treatment approved', "urn:cspace:core.collectionspace.org:vocabularies:name(conservationstatus):item:name(treatmentapproved)'Treatment approved'"],
      ['vocabularies', 'conservationstatus', 'Treatment in progress', "urn:cspace:core.collectionspace.org:vocabularies:name(conservationstatus):item:name(treatmentinprogress)'Treatment in progress'"],
      ['vocabularies', 'currency', 'Canadian Dollar', "urn:cspace:core.collectionspace.org:vocabularies:name(currency):item:name(CAD)'Canadian Dollar'"],
      ['vocabularies', 'currency', 'Danish Krone', "urn:cspace:core.collectionspace.org:vocabularies:name(currency):item:name(DKK)'Danish Krone'"],
      ['vocabularies', 'currency', 'Euro', "urn:cspace:core.collectionspace.org:vocabularies:name(currency):item:name(EUR)'Euro'"],
      ['vocabularies', 'currency', 'Pound Sterling', "urn:cspace:core.collectionspace.org:vocabularies:name(currency):item:name(GBP)'Pound Sterling'"],
      ['vocabularies', 'currency', 'Swedish Krona', "urn:cspace:core.collectionspace.org:vocabularies:name(currency):item:name(SEK)'Swedish Krona'"],
      ['vocabularies', 'currency', 'Swiss Franc', "urn:cspace:core.collectionspace.org:vocabularies:name(currency):item:name(CHF)'Swiss Franc'"],
      ['vocabularies', 'datecertainty', 'Circa', "urn:cspace:core.collectionspace.org:vocabularies:name(datecertainty):item:name(circa)'Circa'"],
      ['vocabularies', 'dateera', 'BCE', "urn:cspace:core.collectionspace.org:vocabularies:name(dateera):item:name(bce)'BCE'"],
      ['vocabularies', 'dateera', 'CE', "urn:cspace:core.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'"],
      ['vocabularies', 'datequalifier', 'Day(s)', "urn:cspace:core.collectionspace.org:vocabularies:name(datequalifier):item:name(days)'Day(s)'"],
      ['vocabularies', 'datequalifier', 'Year(s)', "urn:cspace:core.collectionspace.org:vocabularies:name(datequalifier):item:name(years)'Year(s)'"],
      ['vocabularies', 'deaccessionapprovalgroup', 'board of trustees', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(board_of_trustees)'board of trustees'"],
      ['vocabularies', 'deaccessionapprovalgroup', 'collection committee', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(collection_committee)'collection committee'"],
      ['vocabularies', 'deaccessionapprovalgroup', 'executive committee', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(executive_committee)'executive committee'"],
      ['vocabularies', 'deaccessionapprovalstatus', 'approved', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(approved)'approved'"],
      ['vocabularies', 'deaccessionapprovalstatus', 'not approved', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(not_approved)'not approved'"],
      ['vocabularies', 'deaccessionapprovalstatus', 'not required', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(not_required)'not required'"],
      ['vocabularies', 'disposalmethod', 'destruction', "urn:cspace:core.collectionspace.org:vocabularies:name(disposalmethod):item:name(destruction)'destruction'"],
      ['vocabularies', 'entrymethod', 'Found on doorstep', "urn:cspace:core.collectionspace.org:vocabularies:name(entrymethod):item:name(foundondoorstep)'Found on doorstep'"],
      ['vocabularies', 'entrymethod', 'Post', "urn:cspace:core.collectionspace.org:vocabularies:name(entrymethod):item:name(post)'Post'"],
      ['vocabularies', 'examinationphase', 'before treatment', "urn:cspace:core.collectionspace.org:vocabularies:name(examinationphase):item:name(beforetreatment)'before treatment'"],
      ['vocabularies', 'examinationphase', 'during treatment', "urn:cspace:core.collectionspace.org:vocabularies:name(examinationphase):item:name(duringtreatment)'during treatment'"],
      ['vocabularies', 'exhibitionpersonrole', 'Educator', "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionpersonrole):item:name(educator)'Educator'"],
      ['vocabularies', 'exhibitionpersonrole', 'Public programs coordinator', "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionpersonrole):item:name(publicprogramscoordinator)'Public programs coordinator'"],
      ['vocabularies', 'exhibitionreferencetype', 'News article', "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionreferencetype):item:name(newsarticle)'News article'"],
      ['vocabularies', 'exhibitionreferencetype', 'Press release', "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionreferencetype):item:name(pressrelease)'Press release'"],
      ['vocabularies', 'exhibitionstatus', 'Preliminary object list created', "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionstatus):item:name(preliminaryobjectlistcreated)'Preliminary object list created'"],
      ['vocabularies', 'exhibitiontype', 'Temporary', "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitiontype):item:name(temporary)'Temporary'"],
      ['vocabularies', 'inventorystatus', 'accession status unclear', "urn:cspace:core.collectionspace.org:vocabularies:name(inventorystatus):item:name(accessionstatusunclear)'accession status unclear'"],
      ['vocabularies', 'inventorystatus', 'destroyed', "urn:cspace:core.collectionspace.org:vocabularies:name(inventorystatus):item:name(destroyed)'destroyed'"],
      ['vocabularies', 'inventorystatus', 'unknown', "urn:cspace:core.collectionspace.org:vocabularies:name(inventorystatus):item:name(unknown)'unknown'"],
      ['vocabularies', 'languages', 'Ancient Greek', "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(grc)'Ancient Greek'"],
      ['vocabularies', 'languages', 'Armenian', "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(hye)'Armenian'"],
      ['vocabularies', 'languages', 'English', "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(eng)'English'"],
      ['vocabularies', 'languages', 'French', "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(fra)'French'"],
      ['vocabularies', 'languages', 'Malaysian', "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(mal)'Malaysian'"],
      ['vocabularies', 'languages', 'Spanish', "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(spa)'Spanish'"],
      ['vocabularies', 'languages', 'Swahili', "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(swa)'Swahili'"],
      ['vocabularies', 'loanoutstatus', 'Authorized', "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(authorized)'Authorized'"],
      ['vocabularies', 'loanoutstatus', 'Photography requested', "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(photographyrequested)'Photography requested'"],
      ['vocabularies', 'loanoutstatus', 'Refused', "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(refused)'Refused'"],
      ['vocabularies', 'loanoutstatus', 'Returned', "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(returned)'Returned'"],
      ['vocabularies', 'newsarticle', 'News article', "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionreferencetype):item:name(newsarticle)'News article'"],
      ['vocabularies', 'otherpartyrole', 'Preparator', "urn:cspace:core.collectionspace.org:vocabularies:name(otherpartyrole):item:name(preparator)'Preparator'"],
      ['vocabularies', 'otherpartyrole', 'Technician', "urn:cspace:core.collectionspace.org:vocabularies:name(otherpartyrole):item:name(technician)'Technician'"],
      ['vocabularies', 'publishto', 'CollectionSpace Public Browser', "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(cspacepub)'CollectionSpace Public Browser'"],
      ['vocabularies', 'publishto', 'Culture Object', "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(cultureobject)'Culture Object'"],
      ['vocabularies', 'publishto', 'None', "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(none)'None'"],
      ['vocabularies', 'publishto', 'Omeka', "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(omeka)'Omeka'"],
      ['vocabularies', 'treatmentpurpose', 'Exhibition', "urn:cspace:core.collectionspace.org:vocabularies:name(treatmentpurpose):item:name(exhibition)'Exhibition'"],
      ['vocabularies', 'uocauthorizationstatuses', 'Approved', "urn:cspace:core.collectionspace.org:vocabularies:name(uocauthorizationstatuses):item:name(approved)'Approved'"],
      ['vocabularies', 'uoccollectiontypes', 'archeology', "urn:cspace:core.collectionspace.org:vocabularies:name(uoccollectiontypes):item:name(uocarcheology)'archeology'"],
      ['vocabularies', 'uocmaterialtypes', 'bulb', "urn:cspace:core.collectionspace.org:vocabularies:name(uocmaterialtypes):item:name(bulb)'bulb'"],
      ['vocabularies', 'uocmethods', 'class', "urn:cspace:core.collectionspace.org:vocabularies:name(uocmethods):item:name(class)'class'"],
      ['vocabularies', 'uocstaffroles', 'greeter', "urn:cspace:core.collectionspace.org:vocabularies:name(uocstaffroles):item:name(greeter)'greeter'"],
      ['vocabularies', 'uocsubcollections', 'Asia', "urn:cspace:core.collectionspace.org:vocabularies:name(uocsubcollections):item:name(uocsubcollection02)'Asia'"],
      ['vocabularies', 'uocuserroles', 'faculty', "urn:cspace:core.collectionspace.org:vocabularies:name(uocuserroles):item:name(faculty)'faculty'"],
      ['vocabularies', 'uocusertypes', 'lecturer', "urn:cspace:core.collectionspace.org:vocabularies:name(uocusertypes):item:name(lecturer)'lecturer'"],
      ['workauthorities', 'work', 'Makeup', "urn:cspace:core.collectionspace.org:workauthorities:name(work):item:name(Makeup1608768998350)'Makeup'"],
    ]
    populate(cache, terms)
  end
end

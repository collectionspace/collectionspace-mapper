# frozen_string_literal: true

require_relative './helpers'

module Helpers
  def core_client
    client = CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'https://core.dev.collectionspace.org/cspace-services',
        username: 'admin@core.collectionspace.org',
        password: 'Administrator'
      )
    )
    client
  end
  memo_wise(:core_client)

  def core_cache
    cache_config = base_cache_config.merge({ domain: core_client.domain })
    cache = CollectionSpace::RefCache.new(config: cache_config)
    populate_core(cache)
    cache
  end
  memo_wise(:core_cache)

  def csid_cache
    cache_config = base_cache_config.merge({ domain: core_client.domain })
    cache = CollectionSpace::RefCache.new(config: cache_config)
    populate_csids(cache)
    cache
  end
  memo_wise(:csid_cache)

  def core_object_mapper
    path = 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_collectionobject.json'
    get_record_mapper_object(path, core_cache)
  end

  def populate_core(cache)
    terms = [
      ['citationauthorities', 'citation', 'Arthur',
       {refname: "urn:cspace:core.collectionspace.org:citationauthorities:name(citation):item:name(Arthur62605812848)'Arthur'", csid: '1111-2222-3333-4444'}],
      ['citationauthorities', 'citation', 'Harding',
       {refname: "urn:cspace:core.collectionspace.org:citationauthorities:name(citation):item:name(Harding2510592089)'Harding'", csid: '1111-2222-3333-4444'}],
      ['citationauthorities', 'citation', 'Wanting',
       {refname: "urn:cspace:core.collectionspace.org:citationauthorities:name(citation):item:name(Wanting1599560009399)'Wanting'", csid: '1111-2222-3333-4444'}],
      ['citationauthorities', 'citation', 'makasi',
       {refname: "urn:cspace:core.collectionspace.org:citationauthorities:name(citation):item:name(makasi1599645537547)'makasi'", csid: '1111-2222-3333-4444'}],
      ['citationauthorities', 'worldcat', 'Chelse',
       {refname: "urn:cspace:core.collectionspace.org:citationauthorities:name(worldcat):item:name(Chelse1599645525740)'Chelse'", csid: '1111-2222-3333-4444'}],
      ['citationauthorities', 'worldcat', 'Patiently',
       {refname: "urn:cspace:core.collectionspace.org:citationauthorities:name(worldcat):item:name(Patiently1599559993332)'Patiently'", csid: '1111-2222-3333-4444'}],
      ['collectionobjects', '', 'Hierarchy Test 001',
       {refname: "urn:cspace:core.collectionspace.org:collectionobjects:id(16161bff-b01a-4b55-95aa)'Hierarchy Test 001'", csid: '16161bff-b01a-4b55-95aa'}],
      ['conceptauthorities', 'concept', 'Test',
       {refname: "urn:cspace:core.collectionspace.org:conceptauthorities:name(concept):item:name(Test1599650854716)'Test'", csid: '1111-2222-3333-4444'}],
      ['conceptauthorities', 'concept', 'Sample Concept 1',
       {refname: "urn:cspace:core.collectionspace.org:conceptauthorities:name(concept):item:name(SampleConcept11581354228875)'Sample Concept 1'", csid: '1111-2222-3333-4444'}],
      ['conceptauthorities', 'concept', 'Uno',
       {refname: "urn:cspace:core.collectionspace.org:conceptauthorities:name(concept):item:name(Uno1599645111177)'Uno'", csid: '1111-2222-3333-4444'}],
      ['conceptauthorities', 'occasion', 'Computer',
       {refname: "urn:cspace:core.collectionspace.org:conceptauthorities:name(occasion):item:name(Computer1599734104251)'Computer'", csid: '1111-2222-3333-4444'}],
      ['locationauthorities', 'indeterminate', '~Indeterminate Location~',
       {refname: "urn:cspace:indeterminate:locationauthorities:name(indeterminate):item:name(indeterminate)'~Indeterminate Location~'", csid: '1111-2222-3333-4444'}],
      ['locationauthorities', 'location', 'Abardares',
       {refname: "urn:cspace:core.collectionspace.org:locationauthorities:name(location):item:name(Abardares1599557570049)'Abardares'", csid: '1111-2222-3333-4444'}],
      ['locationauthorities', 'location', 'Kalif',
       {refname: "urn:cspace:core.collectionspace.org:locationauthorities:name(location):item:name(Kalif1599734233745)'Kalif'", csid: '1111-2222-3333-4444'}],
      ['locationauthorities', 'location', 'Khago',
       {refname: "urn:cspace:core.collectionspace.org:locationauthorities:name(location):item:name(Khago1599559772718)'Khago'", csid: '1111-2222-3333-4444'}],
      ['locationauthorities', 'location', 'Stay',
       {refname: "urn:cspace:core.collectionspace.org:locationauthorities:name(offsite_sla):item:name(Stay1599559824865)'Stay'", csid: '1111-2222-3333-4444'}],
      ['locationauthorities', 'offsite_sla', 'Lavington',
       {refname: "urn:cspace:core.collectionspace.org:locationauthorities:name(offsite_sla):item:name(Lavington1599144699983)'Lavington'", csid: '1111-2222-3333-4444'}],
      ['locationauthorities', 'offsite_sla', 'Ngong',
       {refname: "urn:cspace:core.collectionspace.org:locationauthorities:name(offsite_sla):item:name(Ngong1599557586466)'Ngong'", csid: '1111-2222-3333-4444'}],
      ['locationauthorities', 'offsite_sla', 'Stay',
       {refname: "urn:cspace:core.collectionspace.org:locationauthorities:name(offsite_sla):item:name(Stay)'Stay'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', '2021',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(20211599147173971)'2021'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Astroworld',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Astroworld1599650794829)'Astroworld'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Broker',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Broker1599221487572)'Broker'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'But Ohh',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(ButOhh1599665031368)'But Ohh'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Cuckoo',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Cuckoo1599463786824)'Cuckoo'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Ibiza',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Ibiza1599650806827)'Ibiza'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Joseph Hills',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(JosephHills1599463935463)'Joseph Hills'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Kremling',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Kremling1599464161204)'Kremling'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'MMG',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(MMG1599569514486)'MMG'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Martin',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Martin1599559712783)'Martin'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Ninja',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Ninja1599147339325)'Ninja'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Oval',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Oval1599650891221)'Oval'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Podoa',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Podoa1599645346399)'Podoa'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Rock Nation',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(RockNation1599569481908)'Rock Nation'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Sidarec',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Sidarec1599210955079)'Sidarec'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'TIm Herod',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(TImHerod1599144655199)'TIm Herod'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Tasia',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Tasia1599734050597)'Tasia'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Tesla',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Tesla1599144565539)'Tesla'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'Walai',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Walai1599645181370)'Walai'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'breakup',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(breakup1599559909048)'breakup'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'fggf',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(fggf1599552009173)'fggf'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'pandemic',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(pandemic1599645036126)'pandemic'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'pop',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(pop1599664789385)'pop'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'pupu',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(pupu1599645415676)'pupu'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'organization', 'tent',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(tent1599664807586)'tent'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'ulan_oa', 'Again',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(ulan_oa):item:name(Again1599559881266)'Again'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'ulan_oa', 'Signal',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(ulan_oa):item:name(Signal1599559737158)'Signal'", csid: '1111-2222-3333-4444'}],
      ['orgauthorities', 'ulan_oa', 'Very fats',
       {refname: "urn:cspace:core.collectionspace.org:orgauthorities:name(ulan_oa):item:name(Veryfats1599645188567)'Very fats'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Broooks',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Broooks1599221558583)'Broooks'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', '2020',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(20201599147149106)'2020'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', '254Glock',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(254Glock1599569494651)'254Glock'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Abel',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Abel1599464025893)'Abel'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Alexa',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Alexa1599557607978)'Alexa'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Andrew Watts',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(AndrewWatts1599144553996)'Andrew Watts'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Busy',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Busy1599559723432)'Busy'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Cardi',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Cardi1599569468209)'Cardi'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Clemo',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Clemo1599221473000)'Clemo'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Clon',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Clon1599569543362)'Clon'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Comodore',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Comodore1599463826401)'Comodore'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Comrade',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Comrade1599664745661)'Comrade'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Cooper Phil',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(CooperPhil1599144599479)'Cooper Phil'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Disturb',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Disturb1599665062738)'Disturb'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Dudu',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Dudu1599645410044)'Dudu'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Erick',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Erick1599734121151)'Erick'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'First Layer',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(FirstLayer1599463905818)'First Layer'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Glock',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Glock1599580905730)'Glock'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Gomongo',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Gomongo1599463746195)'Gomongo'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Grace',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Grace1599569599918)'Grace'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Henry',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Henry1599210937770)'Henry'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Home Alone',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(HomeAlone1599144524188)'Home Alone'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'James',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(James1599210943727)'James'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Jamo',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Jamo1599221465693)'Jamo'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Joel',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Joel1599557736045)'Joel'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'John Allen',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(JohnAllen1599144390263)'John Allen'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'John Kay',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(JohnKay1599210868122)'John Kay'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Kali',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kali1599221504661)'Kali'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Karanja',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Karanja1599211015378)'Karanja'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Kev',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kev1599058769862)'Kev'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Kimani',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kimani1599210926973)'Kimani'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Kimonda',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kimonda1599211004900)'Kimonda'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'King Kosa',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(KingKosa1599569726990)'King Kosa'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Kinuthia',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kinuthia1599734017515)'Kinuthia'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Lebron',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Lebron1599557725925)'Lebron'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Lima',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Lima1599645323459)'Lima'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Loan',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Loan1599210896616)'Loan'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Mark Smith',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(MarkSmith)'Mark Smith'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Meghan',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Meghan1599569567326)'Meghan'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Nyauma',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Nyauma1599210983879)'Nyauma'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Scribe',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Scribe1599645240974)'Scribe'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Shen Yeng',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(ShenYeng1599569685887)'Shen Yeng'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Soi',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Soi1599734190999)'Soi'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Switch',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Switch1599645085995)'Switch'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Tim Joes',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(TimJoes1599144424859)'Tim Joes'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Trepoz',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Trepoz1599221497512)'Trepoz'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Trevor',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Trevor1599144536281)'Trevor'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'Troy',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Troy1599144360617)'Troy'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'afa',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(afa1599645004939)'afa'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'cxcx',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(cxcx1599551790384)'cxcx'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'dfdd',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(dfdd1599551799173)'dfdd'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'dssd',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(dssd1599552004115)'dssd'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'fgfgf',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(fgfgf1599551987166)'fgfgf'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'giri',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(giri1599645613143)'giri'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'high grade',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(highgrade1599645597889)'high grade'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'malik',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(malik1599664876144)'malik'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'marcus',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(marcus1599650918612)'marcus'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'marley',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(marley1599650874712)'marley'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'rights',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(rights1599650868011)'rights'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'rudelyt',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(rudelyt1599664917218)'rudelyt'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'sasa',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(sasa1599551852678)'sasa'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'tint',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(tint1599664800144)'tint'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'tonight',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(tonight1599664781376)'tonight'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'ulan_pa', 'Chrus',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(ulan_pa):item:name(Chrus1599559702930)'Chrus'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'ulan_pa', 'We go',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(ulan_pa):item:name(Wego1599559866517)'We go'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'ulan_pa', 'panda nayo',
       {refname: "urn:cspace:core.collectionspace.org:personauthorities:name(ulan_pa):item:name(pandanayo1599645094507)'panda nayo'", csid: '1111-2222-3333-4444'}],
      ['placeauthorities', 'place', 'Chillspot',
       {refname: "urn:cspace:core.collectionspace.org:placeauthorities:name(place):item:name(Chillspot1599145441945)'Chillspot'", csid: '1111-2222-3333-4444'}],
      ['placeauthorities', 'tgn_place', 'mzingga',
       {refname: "urn:cspace:core.collectionspace.org:placeauthorities:name(tgn_place):item:name(mzingga1599645587502)'mzingga'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'agequalifier', 'older than',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(agequalifier):item:name(olderthan)'older than'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'collectionmethod', 'donation',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(collectionmethod):item:name(donation)'donation'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'collectionmethod', 'excavation',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(collectionmethod):item:name(excavation)'excavation'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'conditioncheckmethod', 'Observed',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(conditioncheckmethod):item:name(observed)'Observed'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'conditioncheckreason', 'Damaged in transit',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(conditioncheckreason):item:name(damagedintransit)'Damaged in transit'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'conditionfitness', 'Reasonable',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(conditionfitness):item:name(reasonable)'Reasonable'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'conservationstatus', 'Analysis complete',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(conservationstatus):item:name(analysiscomplete)'Analysis complete'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'conservationstatus', 'Treatment approved',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(conservationstatus):item:name(treatmentapproved)'Treatment approved'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'conservationstatus', 'Treatment in progress',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(conservationstatus):item:name(treatmentinprogress)'Treatment in progress'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'currency', 'Canadian Dollar',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(currency):item:name(CAD)'Canadian Dollar'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'currency', 'Danish Krone',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(currency):item:name(DKK)'Danish Krone'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'currency', 'Euro',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(currency):item:name(EUR)'Euro'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'currency', 'Pound Sterling',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(currency):item:name(GBP)'Pound Sterling'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'currency', 'Swedish Krona',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(currency):item:name(SEK)'Swedish Krona'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'currency', 'Swiss Franc',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(currency):item:name(CHF)'Swiss Franc'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'datecertainty', 'Circa',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(datecertainty):item:name(circa)'Circa'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'dateera', 'BCE',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(dateera):item:name(bce)'BCE'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'dateera', 'CE',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'datequalifier', 'Day(s)',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(datequalifier):item:name(days)'Day(s)'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'datequalifier', 'Year(s)',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(datequalifier):item:name(years)'Year(s)'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'deaccessionapprovalgroup', 'board of trustees',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(board_of_trustees)'board of trustees'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'deaccessionapprovalgroup', 'collection committee',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(collection_committee)'collection committee'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'deaccessionapprovalgroup', 'executive committee',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(executive_committee)'executive committee'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'deaccessionapprovalstatus', 'approved',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(approved)'approved'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'deaccessionapprovalstatus', 'not approved',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(not_approved)'not approved'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'deaccessionapprovalstatus', 'not required',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(not_required)'not required'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'disposalmethod', 'destruction',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(disposalmethod):item:name(destruction)'destruction'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'entrymethod', 'Found on doorstep',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(entrymethod):item:name(foundondoorstep)'Found on doorstep'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'entrymethod', 'Post',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(entrymethod):item:name(post)'Post'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'examinationphase', 'before treatment',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(examinationphase):item:name(beforetreatment)'before treatment'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'examinationphase', 'during treatment',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(examinationphase):item:name(duringtreatment)'during treatment'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'exhibitionpersonrole', 'Educator',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionpersonrole):item:name(educator)'Educator'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'exhibitionpersonrole', 'Public programs coordinator',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionpersonrole):item:name(publicprogramscoordinator)'Public programs coordinator'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'exhibitionreferencetype', 'News article',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionreferencetype):item:name(newsarticle)'News article'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'exhibitionreferencetype', 'Press release',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionreferencetype):item:name(pressrelease)'Press release'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'exhibitionstatus', 'Preliminary object list created',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionstatus):item:name(preliminaryobjectlistcreated)'Preliminary object list created'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'exhibitiontype', 'Temporary',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitiontype):item:name(temporary)'Temporary'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'inventorystatus', 'accession status unclear',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(inventorystatus):item:name(accessionstatusunclear)'accession status unclear'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'inventorystatus', 'destroyed',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(inventorystatus):item:name(destroyed)'destroyed'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'inventorystatus', 'unknown',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(inventorystatus):item:name(unknown)'unknown'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'languages', 'Ancient Greek',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(grc)'Ancient Greek'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'languages', 'Armenian',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(hye)'Armenian'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'languages', 'English',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(eng)'English'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'languages', 'French',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(fra)'French'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'languages', 'Malaysian',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(mal)'Malaysian'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'languages', 'Spanish',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(spa)'Spanish'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'languages', 'Swahili',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(swa)'Swahili'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'loanoutstatus', 'Authorized',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(authorized)'Authorized'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'loanoutstatus', 'Photography requested',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(photographyrequested)'Photography requested'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'loanoutstatus', 'Refused',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(refused)'Refused'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'loanoutstatus', 'Returned',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(returned)'Returned'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'newsarticle', 'News article',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionreferencetype):item:name(newsarticle)'News article'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'otherpartyrole', 'Preparator',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(otherpartyrole):item:name(preparator)'Preparator'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'otherpartyrole', 'Technician',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(otherpartyrole):item:name(technician)'Technician'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'publishto', 'CollectionSpace Public Browser',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(cspacepub)'CollectionSpace Public Browser'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'publishto', 'Culture Object',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(cultureobject)'Culture Object'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'publishto', 'None',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(none)'None'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'publishto', 'Omeka',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(omeka)'Omeka'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'treatmentpurpose', 'Exhibition',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(treatmentpurpose):item:name(exhibition)'Exhibition'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'uocauthorizationstatuses', 'Approved',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(uocauthorizationstatuses):item:name(approved)'Approved'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'uoccollectiontypes', 'archeology',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(uoccollectiontypes):item:name(uocarcheology)'archeology'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'uocmaterialtypes', 'bulb',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(uocmaterialtypes):item:name(bulb)'bulb'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'uocmethods', 'class',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(uocmethods):item:name(class)'class'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'uocstaffroles', 'greeter',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(uocstaffroles):item:name(greeter)'greeter'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'uocsubcollections', 'Asia',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(uocsubcollections):item:name(uocsubcollection02)'Asia'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'uocuserroles', 'faculty',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(uocuserroles):item:name(faculty)'faculty'", csid: '1111-2222-3333-4444'}],
      ['vocabularies', 'uocusertypes', 'lecturer',
       {refname: "urn:cspace:core.collectionspace.org:vocabularies:name(uocusertypes):item:name(lecturer)'lecturer'", csid: '1111-2222-3333-4444'}],
      ['workauthorities', 'work', 'Makeup',
       {refname: "urn:cspace:core.collectionspace.org:workauthorities:name(work):item:name(Makeup1608768998350)'Makeup'", csid: '1111-2222-3333-4444'}],
      ['personauthorities', 'person', 'John Doe', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(JohnDoe1416422840)'John Doe'"]
    ]
    populate(cache, terms)
  end

    def populate_csids(cache)
    terms = [
      ['personauthorities', 'person', 'John Doe', '123'],
    ]
    populate(cache, terms)
  end
end

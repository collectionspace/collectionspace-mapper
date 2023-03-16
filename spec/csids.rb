# frozen_string_literal: true

module Helpers
  def cacheable_csids
    [
      # These are known to be needed/expected by tests
      ["acquisitions", nil, "ACQ 123", "8976-1265-9921-ab75"],
      ["collectionobjects", "", "Hierarchy Test 001", "7976-7265-3715-6363"],
      ["conceptauthorities", "concept", "Sample Concept 1",
        "3736-2250-1869-4155"],
      ["hier", "22706401-8328-4778-86fa", "8e74756f-38f5-4dee-90d4",
        "xcvb-1234-9191-0000"],
      ["nhr", "22706401-8328-4778-86fa", "8e74756f-38f5-4dee-90d4",
        "xcvb-1234-9191-0000"],
      ["personauthorities", "person", "John Doe", "6369-4346-1059-9571"],
      # These are not -- they haven't all been checked!
      ["citationauthorities", "citation", "Arthur", "8558-5659-2886-1318"],
      ["citationauthorities", "citation", "FNA Volume 19",
        "8376-2428-6810-2705"],
      ["citationauthorities", "citation", "Harding", "7652-1509-4094-4288"],
      ["citationauthorities", "citation", "Sp. Pl. 2: 899. 1753",
        "5588-9512-8452-1253"],
      ["citationauthorities", "citation", "Wanting", "3909-1472-3508-9314"],
      ["citationauthorities", "citation", "makasi", "3955-6978-3064-5015"],
      ["citationauthorities", "worldcat", "Bull. Torrey Bot. Club",
        "6643-2003-1765-6994"],
      ["citationauthorities", "worldcat", "Chelse", "9692-1789-9270-8775"],
      ["citationauthorities", "worldcat", "Patiently", "5536-2042-3024-7822"],
      ["conceptauthorities", "archculture", "Blackfoot", "9871-8969-7771-3885"],
      ["conceptauthorities", "concept", "Birds", "2265-5999-2095-5769"],
      ["conceptauthorities", "concept", "Official", "4895-7432-6784-8378"],
      ["conceptauthorities", "concept", "Test", "8238-2740-8186-6377"],
      ["conceptauthorities", "concept", "Uno", "1868-0979-0346-6153"],
      ["conceptauthorities", "ethculture", "Batak", "7874-4486-0564-2928"],
      ["conceptauthorities", "ethculture", "Got", "2209-5196-2172-3881"],
      ["conceptauthorities", "ethculture", "Hero", "0585-5584-6931-8594"],
      ["conceptauthorities", "material_ca", "Feathers", "1368-1936-4534-1391"],
      ["conceptauthorities", "occasion", "Computer", "3511-3563-1593-3080"],
      ["locationauthorities", "indeterminate", "~Indeterminate Location~",
        "6550-9457-8092-2010"],
      ["locationauthorities", "location", "Abardares", "1950-3557-8257-4960"],
      ["locationauthorities", "location", "Corner", "3239-7533-9099-4113"],
      ["locationauthorities", "location", "Kalif", "0496-9825-1581-9944"],
      ["locationauthorities", "location", "Khago", "7114-5663-0788-5487"],
      ["locationauthorities", "location", "Stay", "9647-9939-8184-1116"],
      ["locationauthorities", "offsite_sla", "Lavington",
        "0075-7235-8017-4186"],
      ["locationauthorities", "offsite_sla", "Ngong", "6555-7523-8118-8949"],
      ["locationauthorities", "offsite_sla", "Stay", "4714-4307-0975-0641"],
      ["orgauthorities", "organization", "2021", "4127-3873-8407-7066"],
      ["orgauthorities", "organization", "Astroworld", "1500-5904-1267-5294"],
      ["orgauthorities", "organization", "Bonsai Museum",
        "1060-3655-0331-5347"],
      ["orgauthorities", "organization", "Bonsai Store", "5235-5008-5020-8693"],
      ["orgauthorities", "organization", "Broker", "1669-5237-2871-2683"],
      ["orgauthorities", "organization", "But Ohh", "5321-9047-1878-8322"],
      ["orgauthorities", "organization", "Cuckoo", "6321-1155-5024-0883"],
      ["orgauthorities", "organization", "FVA", "7562-8602-3412-9552"],
      ["orgauthorities", "organization", "Hola", "6071-7974-3622-1009"],
      ["orgauthorities", "organization", "Ibiza", "6863-4350-8377-8609"],
      ["orgauthorities", "organization", "Joseph Hills", "7843-4163-1681-8475"],
      ["orgauthorities", "organization", "Kremling", "6281-8893-7314-9290"],
      ["orgauthorities", "organization", "MMG", "6371-5371-3259-2941"],
      ["orgauthorities", "organization", "Martin", "8178-0814-4708-8714"],
      ["orgauthorities", "organization", "Ninja", "2689-4536-4345-1856"],
      ["orgauthorities", "organization", "Organization 1",
        "6014-0563-7275-7116"],
      ["orgauthorities", "organization", "Oval", "2477-2519-9464-5452"],
      ["orgauthorities", "organization", "Podoa", "9692-5408-0068-3403"],
      ["orgauthorities", "organization", "Rock Nation", "7655-7967-9636-9073"],
      ["orgauthorities", "organization", "Sidarec", "2924-6892-7565-4418"],
      ["orgauthorities", "organization", "TIm Herod", "0933-2868-8281-6803"],
      ["orgauthorities", "organization", "Tasia", "0036-7854-4574-2391"],
      ["orgauthorities", "organization", "Tesla", "8626-7949-9043-4802"],
      ["orgauthorities", "organization", "Walai", "8678-5036-4204-2968"],
      ["orgauthorities", "organization", "breakup", "4584-5363-2878-3015"],
      ["orgauthorities", "organization", "chores", "1817-0917-2452-8280"],
      ["orgauthorities", "organization", "fggf", "9016-6902-2545-4171"],
      ["orgauthorities", "organization", "pandemic", "4212-7991-7286-7438"],
      ["orgauthorities", "organization", "pop", "8468-0336-4708-3778"],
      ["orgauthorities", "organization", "pupu", "2243-2777-3535-7416"],
      ["orgauthorities", "organization", "tent", "3930-0339-3088-4928"],
      ["orgauthorities", "ulan_oa", "Again", "6421-9501-7800-6962"],
      ["orgauthorities", "ulan_oa", "Signal", "8264-9896-0637-8899"],
      ["orgauthorities", "ulan_oa", "Very fats", "4729-6415-0497-9814"],
      ["personauthorities", "person", "2020", "1739-4698-5074-8195"],
      ["personauthorities", "person", "254Glock", "7687-4340-6887-2031"],
      ["personauthorities", "person", "Abel", "4922-0930-1741-2701"],
      ["personauthorities", "person", "Alexa", "7568-9055-4348-3286"],
      ["personauthorities", "person", "Andrew Watts", "5084-9900-7305-0885"],
      ["personauthorities", "person", "Ann Analyst", "1934-9133-6236-3846"],
      ["personauthorities", "person", "Ann Authorizer", "4638-7546-2757-9670"],
      ["personauthorities", "person", "Broooks", "8261-6764-4788-8117"],
      ["personauthorities", "person", "Busy", "3701-6911-7557-1034"],
      ["personauthorities", "person", "Cardi", "8185-3578-0060-7154"],
      ["personauthorities", "person", "Clemo", "7428-1771-0329-4648"],
      ["personauthorities", "person", "Clon", "2681-2440-3428-8845"],
      ["personauthorities", "person", "Comodore", "9800-0137-4706-1602"],
      ["personauthorities", "person", "Comrade", "1155-9680-6085-2462"],
      ["personauthorities", "person", "Cooper Phil", "2679-5052-5499-5333"],
      ["personauthorities", "person", "Debbie Depositor",
        "8157-7830-7082-8545"],
      ["personauthorities", "person", "Disturb", "9059-1722-6470-6155"],
      ["personauthorities", "person", "Dudu", "1061-6921-8660-2602"],
      ["personauthorities", "person", "Elizabeth", "8237-7028-4306-4329"],
      ["personauthorities", "person", "Erick", "5570-9573-3173-4084"],
      ["personauthorities", "person", "First Layer", "8890-2883-6375-9279"],
      ["personauthorities", "person", "Gabriel Solares", "0052-4393-1104-5512"],
      ["personauthorities", "person", "Glock", "8963-2750-4974-3034"],
      ["personauthorities", "person", "Gomongo", "9082-1092-1118-9504"],
      ["personauthorities", "person", "Grace", "7899-9673-2394-3499"],
      ["personauthorities", "person", "Henry", "2048-8794-7933-3760"],
      ["personauthorities", "person", "Home Alone", "0160-5899-9186-1125"],
      ["personauthorities", "person", "James", "3999-4837-2245-2811"],
      ["personauthorities", "person", "Jamo", "7684-0739-4777-2687"],
      ["personauthorities", "person", "Joel", "2624-4205-6334-7326"],
      ["personauthorities", "person", "John Allen", "0041-1761-3755-2968"],
      ["personauthorities", "person", "John Kay", "4401-7611-0803-7234"],
      ["personauthorities", "person", "Kali", "8596-7069-1292-3613"],
      ["personauthorities", "person", "Karanja", "9751-3244-3551-0250"],
      ["personauthorities", "person", "Kev", "8499-9425-8411-2508"],
      ["personauthorities", "person", "Kimani", "2552-5292-8938-1722"],
      ["personauthorities", "person", "Kimonda", "5813-5618-9674-7425"],
      ["personauthorities", "person", "King Kosa", "1955-0127-1262-4196"],
      ["personauthorities", "person", "Kinuthia", "6613-9514-8431-4899"],
      ["personauthorities", "person", "Lebron", "7428-0616-7212-8638"],
      ["personauthorities", "person", "Lima", "4844-9680-2147-9400"],
      ["personauthorities", "person", "Linnaeus, Carl", "2476-2148-5398-5854"],
      ["personauthorities", "person", "Loan", "2530-5951-4717-9799"],
      ["personauthorities", "person", "Mark Smith", "3523-9556-0955-3288"],
      ["personauthorities", "person", "Meghan", "2943-8895-3456-1624"],
      ["personauthorities", "person", "Nyauma", "0417-6118-9202-4542"],
      ["personauthorities", "person", "Priscilla Plantsale",
        "6550-9637-3993-9656"],
      ["personauthorities", "person", "Scribe", "4610-4259-1300-2634"],
      ["personauthorities", "person", "Shen Yeng", "3127-7407-5663-8996"],
      ["personauthorities", "person", "Soi", "9733-3188-7284-7897"],
      ["personauthorities", "person", "Switch", "3741-4157-5071-7259"],
      ["personauthorities", "person", "Tegla", "9010-4726-4859-7753"],
      ["personauthorities", "person", "Tim Joes", "0385-8701-2376-3823"],
      ["personauthorities", "person", "Tom", "4339-7388-1155-8574"],
      ["personauthorities", "person", "Trepoz", "9668-1738-5543-7812"],
      ["personauthorities", "person", "Trevor", "1762-8291-1130-2830"],
      ["personauthorities", "person", "Troy", "6876-6651-0733-6162"],
      ["personauthorities", "person", "afa", "7509-1602-0447-8493"],
      ["personauthorities", "person", "cxcx", "8823-5902-6725-4091"],
      ["personauthorities", "person", "dfdd", "8512-4657-6428-1516"],
      ["personauthorities", "person", "dssd", "5139-2300-2588-9691"],
      ["personauthorities", "person", "fgfgf", "0899-1960-8621-7042"],
      ["personauthorities", "person", "fullclip", "1879-5848-4727-0859"],
      ["personauthorities", "person", "giri", "0562-9437-3316-1180"],
      ["personauthorities", "person", "high grade", "6312-1739-0791-6725"],
      ["personauthorities", "person", "jijoe", "6895-7872-9880-6029"],
      ["personauthorities", "person", "malik", "9101-1909-4407-6018"],
      ["personauthorities", "person", "marcus", "9421-6994-1780-4476"],
      ["personauthorities", "person", "marley", "6918-1663-9922-0328"],
      ["personauthorities", "person", "praya", "9165-0645-9221-3679"],
      ["personauthorities", "person", "rights", "6174-4248-6215-5418"],
      ["personauthorities", "person", "rudelyt", "3677-5014-6040-2182"],
      ["personauthorities", "person", "sasa", "2691-2441-9498-2697"],
      ["personauthorities", "person", "sniper", "6333-4905-6710-1413"],
      ["personauthorities", "person", "tint", "0105-3448-6347-9504"],
      ["personauthorities", "person", "tonight", "6438-1323-3479-8477"],
      ["personauthorities", "ulan_pa", "Chrus", "1376-6442-0735-5546"],
      ["personauthorities", "ulan_pa", "We go", "3808-7701-6463-8233"],
      ["personauthorities", "ulan_pa", "panda nayo", "2040-4198-4844-3397"],
      ["placeauthorities", "place", "Chillspot", "0343-1562-7229-1509"],
      ["placeauthorities", "place", "Early", "6702-7261-2546-0905"],
      ["placeauthorities", "place", "Local", "9536-0784-5935-0465"],
      ["placeauthorities", "place", "York County, Pennsylvania",
        "3935-9866-9816-9139"],
      ["placeauthorities", "tgn_place", "mzingga", "4289-7410-6079-5905"],
      ["taxonomyauthority", "taxon", "Domestic", "9489-8212-2272-9713"],
      ["taxonomyauthority", "taxon", "Tropez", "7224-8842-5985-5777"],
      ["vocabularies", "agequalifier", "older than", "5967-5187-1759-3092"],
      ["vocabularies", "agerange", "adolescent 26-75%", "6884-5481-5856-1889"],
      ["vocabularies", "agerange", "adult 0-25%", "3858-3850-8632-8934"],
      ["vocabularies", "annotationtype", "image made", "5178-8491-1673-7381"],
      ["vocabularies", "annotationtype", "type", "3595-1282-1462-6972"],
      ["vocabularies", "behrensmeyer",
        "0 - no cracking or flaking on bone surface", "3326-1750-5327-7581"],
      ["vocabularies", "behrensmeyer",
        "1 - longitudinal and/or mosaic cracking present on surface",
        "7908-5047-1851-2936"],
      ["vocabularies", "behrensmeyer",
        "2 - longitudinal cracks, exfoliation on surface",
        "9952-3369-8128-1850"],
      ["vocabularies", "behrensmeyer",
        "3 - fibrous texture, extensive exfoliation", "2840-1757-4058-9690"],
      ["vocabularies", "behrensmeyer",
        "4 - coarsely fibrous texture, splinters of bone loose on the surface, "\
          "open cracks", "6978-3358-6091-1718"],
      ["vocabularies", "behrensmeyer",
        "5 - bone crumbling in situ, large splinters", "2362-7188-5503-1720"],
      ["vocabularies", "bodyside", "midline", "9350-8042-0202-8217"],
      ["vocabularies", "collectionmethod", "donation", "2441-3300-0397-7736"],
      ["vocabularies", "collectionmethod", "excavation", "2375-0189-5833-0583"],
      ["vocabularies", "conditioncheckmethod", "Observed",
        "4184-8280-2657-5675"],
      ["vocabularies", "conditioncheckreason", "Damaged in transit",
        "9713-8148-8367-8261"],
      ["vocabularies", "conditionfitness", "Reasonable", "8190-8625-6193-6555"],
      ["vocabularies", "conservationstatus", "Analysis complete",
        "2619-7339-9140-0556"],
      ["vocabularies", "conservationstatus", "Treatment approved",
        "6945-4964-1400-3230"],
      ["vocabularies", "conservationstatus", "Treatment in progress",
        "8385-9204-3223-8445"],
      ["vocabularies", "cranialdeformationcategory", "circumferential",
        "6933-9280-3767-6840"],
      ["vocabularies", "cranialdeformationcategory", "other (describe)",
        "1064-5392-9969-9019"],
      ["vocabularies", "cranialdeformationcategory", "tabular",
        "4273-6637-0660-9513"],
      ["vocabularies", "currency", "Canadian Dollar", "7613-8718-8694-2075"],
      ["vocabularies", "currency", "Danish Krone", "0273-0960-9849-4731"],
      ["vocabularies", "currency", "Euro", "6408-3964-5885-2030"],
      ["vocabularies", "currency", "Pound Sterling", "3373-1251-4127-4315"],
      ["vocabularies", "currency", "Swedish Krona", "6453-9921-0601-0554"],
      ["vocabularies", "currency", "Swiss Franc", "2454-3940-4404-8178"],
      ["vocabularies", "cuttingtype", "hardwood", "6094-7409-1252-9038"],
      ["vocabularies", "datecertainty", "Circa", "0225-0697-7049-5080"],
      ["vocabularies", "dateera", "BCE", "6945-2270-4555-4629"],
      ["vocabularies", "dateera", "CE", "4190-6538-3955-9437"],
      ["vocabularies", "datequalifier", "Day(s)", "3150-8577-8531-6596"],
      ["vocabularies", "datequalifier", "Year(s)", "1090-6526-0707-0159"],
      ["vocabularies", "deaccessionapprovalgroup", "board of trustees",
        "4243-5019-2787-9404"],
      ["vocabularies", "deaccessionapprovalgroup", "collection committee",
        "9067-5042-5399-6404"],
      ["vocabularies", "deaccessionapprovalgroup", "executive committee",
        "4687-3956-7102-2911"],
      ["vocabularies", "deaccessionapprovalstatus", "approved",
        "4521-6403-5701-5339"],
      ["vocabularies", "deaccessionapprovalstatus", "not approved",
        "5921-3084-9315-9933"],
      ["vocabularies", "deaccessionapprovalstatus", "not required",
        "8677-7505-9102-9846"],
      ["vocabularies", "dentitionscore", "not applicable",
        "0965-4692-2661-1342"],
      ["vocabularies", "disposalmethod", "destruction", "4068-5873-0178-3181"],
      ["vocabularies", "disposalmethod", "public auction",
        "0785-1450-2258-4345"],
      ["vocabularies", "durationunit", "Days", "5991-3245-2930-0013"],
      ["vocabularies", "durationunit", "Hours", "4793-4778-7110-9430"],
      ["vocabularies", "entrymethod", "Found on doorstep",
        "6489-3737-4010-0870"],
      ["vocabularies", "entrymethod", "Post", "7699-7232-9429-2342"],
      ["vocabularies", "examinationphase", "before treatment",
        "1322-2127-2572-5670"],
      ["vocabularies", "examinationphase", "during treatment",
        "4315-1388-7255-7424"],
      ["vocabularies", "exhibitionpersonrole", "Educator",
        "4352-5778-5213-5852"],
      ["vocabularies", "exhibitionpersonrole", "Public programs coordinator",
        "2879-3691-6832-6621"],
      ["vocabularies", "exhibitionreferencetype", "News article",
        "7190-0752-1966-2113"],
      ["vocabularies", "exhibitionreferencetype", "Press release",
        "1935-8905-4261-7557"],
      ["vocabularies", "exhibitionstatus", "Preliminary object list created",
        "0280-1505-1286-4149"],
      ["vocabularies", "exhibitiontype", "Temporary", "3233-8223-5436-8996"],
      ["vocabularies", "inventorystatus", "accession status unclear",
        "6928-7239-7536-7312"],
      ["vocabularies", "inventorystatus", "accessioned", "9625-5427-9258-2616"],
      ["vocabularies", "inventorystatus", "destroyed", "9048-2248-3792-5948"],
      ["vocabularies", "inventorystatus", "unknown", "5777-3905-5466-2746"],
      ["vocabularies", "languages", "Ancient Greek", "9410-3150-9067-1230"],
      ["vocabularies", "languages", "Armenian", "8578-9339-7089-6634"],
      ["vocabularies", "languages", "Chinese", "6208-3714-4083-1871"],
      ["vocabularies", "languages", "English", "5776-9941-4007-9121"],
      ["vocabularies", "languages", "French", "2659-8599-6687-9772"],
      ["vocabularies", "languages", "German", "5549-8169-0247-4457"],
      ["vocabularies", "languages", "Latin", "9400-0300-0018-6643"],
      ["vocabularies", "languages", "Malaysian", "0909-2670-4468-8432"],
      ["vocabularies", "languages", "Spanish", "5811-7661-8104-3774"],
      ["vocabularies", "languages", "Swahili", "3694-3534-3931-8866"],
      ["vocabularies", "limitationlevel", "recommendation",
        "1839-7476-1158-9123"],
      ["vocabularies", "limitationlevel", "restriction", "9710-5583-0283-2319"],
      ["vocabularies", "limitationtype", "lending", "3240-3715-9118-5849"],
      ["vocabularies", "limitationtype", "publication", "7257-3471-4502-4432"],
      ["vocabularies", "loanoutstatus", "Authorized", "4022-7730-7633-7233"],
      ["vocabularies", "loanoutstatus", "Photography requested",
        "9641-7705-5759-0740"],
      ["vocabularies", "loanoutstatus", "Refused", "4949-9589-4257-4022"],
      ["vocabularies", "loanoutstatus", "Returned", "2073-2572-6608-9033"],
      ["vocabularies", "mortuarytreatment", "burned/unburned bone mixture",
        "4602-4808-7974-1621"],
      ["vocabularies", "mortuarytreatment", "enbalmed", "8404-9161-1555-8147"],
      ["vocabularies", "mortuarytreatment", "excarnated",
        "6486-9602-4789-4873"],
      ["vocabularies", "mortuarytreatment", "mummified", "0284-1241-3660-0158"],
      ["vocabularies", "nagpracategory", "not subject to NAGPRA",
        "8208-4494-3072-9698"],
      ["vocabularies", "nagpracategory", "subject to NAGPRA (unspec.)",
        "4162-9179-6934-2367"],
      ["vocabularies", "nagpraclaimtype",
        "affiliated human skeletal remains (HSR)", "6232-9172-5961-6782"],
      ["vocabularies", "nagpraclaimtype", "needs further research",
        "3492-8911-9546-6579"],
      ["vocabularies", "nagpraclaimtype", "not subject to NAGPRA",
        "0274-6936-9265-5703"],
      ["vocabularies", "nagpraclaimtype", "object of cultural patrimony",
        "5698-4286-0776-5216"],
      ["vocabularies", "nagpraclaimtype", "unassociated funerary object (UFO)",
        "8752-0302-3578-2044"],
      ["vocabularies", "newsarticle", "News article", "0130-6106-8629-0645"],
      ["vocabularies", "osteocompleteness", "mandible only",
        "0749-7428-8960-0662"],
      ["vocabularies", "otherpartyrole", "Preparator", "9085-9056-7290-8549"],
      ["vocabularies", "otherpartyrole", "Technician", "0802-8467-6073-9651"],
      ["vocabularies", "potsize", "1 gal. pot", "4760-8227-0564-7190"],
      ["vocabularies", "prodpeoplerole", "designed after",
        "5177-6183-6268-2668"],
      ["vocabularies", "prodpeoplerole", "traditional makers",
        "8816-7519-6448-7528"],
      ["vocabularies", "propActivityType", "benlate and captan",
        "6212-9584-7788-3632"],
      ["vocabularies", "propChemicals", "benlate and physan",
        "3184-2672-8367-8663"],
      ["vocabularies", "propConditions", "glass cover", "8615-7663-6841-6444"],
      ["vocabularies", "propHormones", "hormone", "5063-4149-2770-3168"],
      ["vocabularies", "propPlantType", "bulbs", "9552-9148-4891-1539"],
      ["vocabularies", "propreason", "conservation", "8047-9094-4237-2629"],
      ["vocabularies", "proptype", "Division", "3346-3142-8308-2510"],
      ["vocabularies", "publishto", "CollectionSpace Public Browser",
        "6575-5990-2138-7970"],
      ["vocabularies", "publishto", "Culture Object", "6320-2119-3572-7018"],
      ["vocabularies", "publishto", "DPLA", "1823-1462-0090-3531"],
      ["vocabularies", "publishto", "None", "6424-5718-0834-7539"],
      ["vocabularies", "publishto", "Omeka", "4528-7737-3544-9594"],
      ["vocabularies", "scarstrat", "boiling water", "6900-0004-3267-0532"],
      ["vocabularies", "scarstrat", "cold strat", "8433-3307-2501-4953"],
      ["vocabularies", "taxontermflag", "invalid", "3890-4164-4319-9260"],
      ["vocabularies", "taxontermflag", "valid", "0915-5895-5412-7835"],
      ["vocabularies", "treatmentpurpose", "Exhibition", "2341-8944-7306-5150"],
      ["vocabularies", "trepanationcertainty", "clear evidence of trepanation",
        "5315-2607-6887-4691"],
      ["vocabularies", "trepanationcertainty", "possible trepanation",
        "1026-5179-4496-2355"],
      ["vocabularies", "trepanationhealing", "definite evidence for healing",
        "4469-2446-9879-8007"],
      ["vocabularies", "trepanationhealing", "no healing",
        "5527-5021-3694-5234"],
      ["vocabularies", "trepanationhealing", "possible healing",
        "8571-3105-6825-9302"],
      ["vocabularies", "trepanationtechnique", "grooving",
        "1667-7418-5259-2407"],
      ["vocabularies", "uocauthorizationstatuses", "Approved",
        "9749-1412-4351-7329"],
      ["vocabularies", "uoccollectiontypes", "archeology",
        "8415-1574-5268-5260"],
      ["vocabularies", "uocmaterialtypes", "bulb", "0980-3593-6210-3455"],
      ["vocabularies", "uocmethods", "class", "4971-2877-1645-1495"],
      ["vocabularies", "uocstaffroles", "greeter", "0302-0801-9308-7984"],
      ["vocabularies", "uocsubcollections", "Asia", "2995-0700-3018-2060"],
      ["vocabularies", "uocuserroles", "faculty", "4287-6573-7370-4744"],
      ["vocabularies", "uocusertypes", "lecturer", "1466-4002-0424-8787"],
      ["workauthorities", "work", "Makeup", "2880-0396-1418-8974"]
    ]
  end
end

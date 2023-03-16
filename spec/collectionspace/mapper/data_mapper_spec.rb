# froze_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataMapper do
  let(:config) { {} }
  let(:jsonmapper) { get_json_record_mapper(mapper_path) }
  let(:handler) do
    CollectionSpace::Mapper::DataHandler.new(
      record_mapper: jsonmapper,
      client: client,
      cache: cache,
      csid_cache: csid_cache,
      config: config
    )
  end
  let(:datahash) { get_datahash(path: datahash_path) }
  let(:prepper) {
    CollectionSpace::Mapper::DataPrepper.new(
      datahash,
      handler.searcher,
      handler
    )
  }
  let(:datamapper) {
    described_class.new(prepper.prep.response, handler, prepper.xphash)
  }
  let(:response) { datamapper.response }
  let(:mapped_doc) { remove_namespaces(response.doc) }
  let(:mapped_xpaths) { list_xpaths(mapped_doc) }
  let(:fixture_doc) { get_xml_fixture(fixture_path) }
  let(:fixture_xpaths) { test_xpaths(fixture_doc, handler.mapper.mappings) }
  let(:diff) { mapped_xpaths - fixture_xpaths }

  context "fcart profile" do
    let(:client) { fcart_client }
    let(:cache) { fcart_cache }
    let(:csid_cache) { fcart_csid_cache }

    context "acquisition record", type: "integration" do
      let(:mapper_path) {
        "spec/fixtures/files/mappers/release_6_1/fcart/"\
          "fcart_3-0-1_acquisition.json"
      }

      it "maps records as expected in sequence" do
        data1 = JSON.parse(
          '{"creditline":"Gift of Frances, 1985","accessiondategroup":"1985",'\
            '"acquisitionmethod":"unknown-provenance","acquisitionreferencenum'\
            'ber":"ACC216 (migrated accession)","acquisitionsourceperson":"","'\
            'acquisitionsourceorganization":"","acquisitionauthorizer":"",'\
            '"acquisitionnote":""}'
        )
        data2 = JSON.parse(
          '{"creditline":"","accessiondategroup":"","acquisitionmethod":'\
            '"unknown-provenance","acquisitionreferencenumber":"ACC215 '\
            '(migrated accession)","acquisitionsourceperson":"","'\
            'acquisitionsourceorganization":"","acquisitionauthorizer":"","'\
            'acquisitionnote":""}'
        )
        data3 = JSON.parse(
          '{"creditline":"Gift of Elizabeth, 1985","accessiondategroup":"1985"'\
            ',"acquisitionmethod":"gift","acquisitionreferencenumber":"ACC208 '\
            '(migrated accession)","acquisitionsourceperson":"Elizabeth","'\
            'acquisitionsourceorganization":"","acquisitionauthorizer":"","'\
            'acquisitionnote":"Acquisition source role(s): Donor"}'
        )
        data = [data1, data2, data3]
        preppers = data.map { |d|
          CollectionSpace::Mapper::DataPrepper.new(d, handler.searcher, handler)
        }
        mappers = preppers.map do |prepper|
          CollectionSpace::Mapper::DataMapper.new(prepper.prep.response,
                                                  handler, prepper.xphash)
        end
        docs = mappers.map { |mapper| remove_namespaces(mapper.response.doc) }
        docxpaths = docs.map { |doc| list_xpaths(doc) }

        fixpaths = ["fcart/acqseq1.xml", "fcart/acqseq2.xml",
                    "fcart/acqseq3.xml"]
        fixdocs = fixpaths.map { |path| get_xml_fixture(path) }
        fixxpaths = fixdocs.map { |doc| list_xpaths(doc) }

        expect(docxpaths).to eq(fixxpaths)
      end
    end
  end

  context "core profile" do
    let(:client) { core_client }
    let(:cache) { core_cache }
    let(:csid_cache) { core_csid_cache }

    context "collectionobject record", type: "integration" do
      let(:mapper_path) {
        "spec/fixtures/files/mappers/release_6_1/core/"\
          "core_6-1-0_collectionobject.json"
      }

      context "overflow subgroup record with uneven subgroup values" do
        let(:datahash_path) {
          "spec/fixtures/files/datahashes/core/collectionobject2.json"
        }
        let(:fixture_path) { "core/collectionobject2.xml" }

        it "mapper response includes overflow subgroup warning" do
          w = response.warnings.any? { |w|
            w[:category] == :subgroup_contains_data_for_nonexistent_groups
          }
          expect(w).to be true
        end
        it "mapper response includes uneven subgroup values warning" do
          w = response.warnings.any? { |w|
            w[:category] == :uneven_subgroup_field_values
          }
          expect(w).to be true
        end
        it "does not map unexpected fields" do
          expect(diff).to eq([])
        end

        it "maps as expected" do
          fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end

      context "overflow subgroup record with even subgroup values" do
        let(:datahash_path) {
          "spec/fixtures/files/datahashes/core/collectionobject3.json"
        }

        it "mapper response does not include overflow subgroup warning" do
          w = response.warnings.any? { |w|
            w[:category] == :subgroup_contains_data_for_nonexistent_groups
          }
          expect(w).to be false
        end
      end
    end

    context "media record", type: "integration" do
      let(:mapper_path) {
        "spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_media.json"
      }

      context "sending through the bomb emoji" do
        let(:datahash_path) {
          "spec/fixtures/files/datahashes/core/media2.json"
        }

        it "sends through an empty node for any field containing bomb" do
          doc = remove_namespaces(datamapper.response.doc)
          xpaths = list_xpaths(doc).reject { |xpath|
            xpath["identificationNumber"]
          }
          vals = []
          xpaths.each { |xpath| vals << doc.xpath(xpath).text }
          expect(vals.uniq).to eq([""])
        end
      end
    end
  end

  context "lhmc profile", type: "integration" do
    let(:client) { lhmc_client }
    let(:cache) { lhmc_cache }
    let(:csid_cache) { lhmc_csid_cache }

    context "person record" do
      let(:mapper_path) {
        "spec/fixtures/files/mappers/release_6_1/lhmc/"\
          "lhmc_3-1-1_person-local.json"
      }
      let(:datahash) { {"termDisplayName" => "Xanadu", "placeNote" => "note"} }

      describe "#add_short_id" do
        let(:short_id_nodeset) { mapped_doc.xpath("//shortIdentifier") }

        it "adds one shortIdentifier element" do
          expect(short_id_nodeset.length).to eq(1)
        end
        it "adds shortIdentifier element to persons_common namespace group" do
          node = short_id_nodeset.first
          expect(node.parent.name).to eq("persons_common")
        end
        it "value of shortIdentifier is as expected" do
          node = short_id_nodeset.first
          expect(node.text).to eq("Xanadu2760257775")
        end
      end

      describe "#set_response_identifier" do
        it "adds record identifier to response" do
          expect(response.identifier).to eq("Xanadu2760257775")
        end
      end
    end
  end

  context "botgarden profile" do
    let(:client) { botgarden_client }
    let(:cache) { botgarden_cache }
    let(:csid_cache) { botgarden_csid_cache }

    context "loanout record" do
      let(:mapper_path) {
        "spec/fixtures/files/mappers/release_6_1/botgarden/"\
          "botgarden_2-0-1_loanout.json"
      }
      let(:datahash) { {"loanOutNumber" => "123", "sterile" => "n"} }

      describe "#set_response_identifier" do
        it "adds record identifier to response" do
          expect(response.identifier).to eq("123")
        end
      end
    end
  end

  context "anthro profile", type: "integration" do
    let(:client) { anthro_client }
    let(:cache) { anthro_cache }
    let(:csid_cache) { anthro_csid_cache }

    context "collectionobject record", services_call: true do
      let(:mapper_path) {
        "spec/fixtures/files/mappers/release_6_1/anthro/"\
          "anthro_4-1-2_collectionobject.json"
      }
      let(:datahash) { anthro_co_1 }
      let(:config) do
        {
          transforms: {
            "collection" => {
              special: %w[downcase_value],
              replacements: [
                {find: " ", replace: "-", type: :plain}
              ]
            },
            "ageRange" => {
              special: %w[downcase_value],
              replacements: [
                {find: " - ", replace: "-", type: :plain}
              ]
            }
          },
          default_values: {
            "publishTo" => "DPLA;Omeka",
            "collection" => "library-collection"
          }
        }
      end

      describe "#doc" do
        let(:result) { datamapper.doc }
        it "returns XML doc" do
          expect(result).to be_a(Nokogiri::XML::Document)
        end
      end

      describe "#response" do
        it "returns CollectionSpace::Mapper::Response object" do
          expect(response).to be_a(CollectionSpace::Mapper::Response)
        end
        it "CollectionSpace::Mapper::Response.doc is XML document" do
          expect(response.doc).to be_a(Nokogiri::XML::Document)
        end
      end

      describe "#add_namespaces" do
        it "adds namespace definitions" do
          urihash = datamapper.handler.mapper.config.ns_uri.clone
          urihash.transform_keys! { |k| "ns2:#{k}" }
          docdefs = {}
          datamapper.doc.xpath("/*/*").each do |ns|
            docdefs[ns.name] = ns.namespace_definitions.select { |d|
              d.prefix == "ns2"
            }.first.href
          end
          unused_keys = urihash.keys - docdefs.keys
          unused_keys.each { |k| urihash.delete(k) }
          expect(docdefs).to eq(urihash)
        end
      end
    end
  end
end

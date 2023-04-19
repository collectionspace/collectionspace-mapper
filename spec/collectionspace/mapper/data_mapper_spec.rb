# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataMapper do
  include_context "data_mapper"

  context "with fcart acquisition", type: 'integration',
    vcr: "fcart_domain_check" do
      let(:profile){ 'fcart' }
      let(:mapper){ "fcart_3-0-1_acquisition" }

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
        docxpaths = data.map{ |dh|
          CollectionSpace::Mapper::Response.new(dh, handler).prep
        }.map{ |dr| dr.map }
          .map { |dr| remove_namespaces(dr.doc) }
          .map { |doc| list_xpaths(doc) }

        fixxpaths = ["fcart/acqseq1.xml", "fcart/acqseq2.xml",
                     "fcart/acqseq3.xml"].map { |path| get_xml_fixture(path) }
          .map { |doc| list_xpaths(doc) }

        expect(docxpaths).to eq(fixxpaths)
      end
    end

  context "when core profile", type: "integration",
    vcr: "core_domain_check" do
      let(:profile){ 'core' }
      context "with collectionobject" do
        let(:mapper){ "core_6-1-0_collectionobject" }

        context "overflow subgroup record with uneven subgroup values" do
          #          skip: "subgroup complications" do
          let(:customcfg){ {delimiter: "|"} }
          let(:datahash_path) {
            "spec/support/datahashes/core/collectionobject2.json"
          }
          let(:fixture_path) { "core/collectionobject2.xml" }

          it "mapper response includes overflow subgroup warning" do
            w = mapped.warnings.any? { |w|
              w[:category] == :subgroup_contains_data_for_nonexistent_groups
            }
            expect(w).to be true
          end

          it "mapper response includes uneven subgroup values warning" do
            w = mapped.warnings.any? { |w|
              w[:category] == :uneven_subgroup_field_values
            }
            expect(w).to be true
          end

          it_behaves_like "Mapped"
        end

        context "overflow subgroup record with even subgroup values" do
          let(:datahash_path) {
            "spec/support/datahashes/core/collectionobject3.json"
          }

          it "mapper response does not include overflow subgroup warning" do
            w = mapped.warnings.any? { |w|
              w[:category] == :subgroup_contains_data_for_nonexistent_groups
            }
            expect(w).to be false
          end
        end
      end

      context "when media ", type: "integration" do
        let(:mapper){ "core_6-1-0_media" }

        context "sending through the bomb emoji" do
          let(:datahash_path) {
            "spec/support/datahashes/core/media2.json"
          }

          it "sends through an empty node for any field containing bomb" do
            doc = remove_namespaces(mapped.doc)
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

  context "with lhmc profile", type: "integration", vcr: "lhmc_domain_check"  do
    let(:profile){ "lhmc" }

    context "with person" do
      let(:mapper){ "lhmc_3-1-1_person-local" }
      let(:datahash) { {"termDisplayName" => "Xanadu", "placeNote" => "note"} }
      let(:short_id_nodeset) { mapped_doc.xpath("//shortIdentifier") }

      it "adds one shortIdentifier element to xml" do
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

      it "adds record identifier to response" do
        expect(mapped.identifier).to eq("Xanadu2760257775")
      end
    end
  end

  context "with botgarden", vcr: "botgarden_domain_check",
    type: "integration" do
      let(:profile){ "botgarden" }

      context "with loanout" do
        let(:mapper){ "botgarden_2-0-1_loanout" }
        let(:datahash) { {"loanOutNumber" => "123", "sterile" => "n"} }

        it "adds record identifier to response" do
          expect(mapped.identifier).to eq("123")
        end
      end
    end

  context "with anthro", type: "integration",
    vcr: "data_mapper_int_anthro" do
      let(:profile){ "anthro" }

      context "with collectionobject" do
        let(:mapper){ "anthro_4-1-2_collectionobject" }

        let(:customcfg) do
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
        let(:datahash) { anthro_co_1 }

        it "adds namespace definitions" do
          urihash = handler.record.ns_uri.clone
          urihash.transform_keys! { |k| "ns2:#{k}" }
          docdefs = {}
          mapped.doc.xpath("/*/*").each do |ns|
            docdefs[ns.name] = ns.namespace_definitions.find { |d|
              d.prefix == "ns2"
            }.href
          end
          unused_keys = urihash.keys - docdefs.keys
          unused_keys.each { |k| urihash.delete(k) }
          expect(docdefs).to eq(urihash)
        end
      end
    end
end

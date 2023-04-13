# frozen_string_literal: true

require "spec_helper"

RSpec.describe CollectionSpace::Mapper::DataMapper, type: "integration" do
  include_context "data_mapper"

  context "core profile" do
    let(:profile){ "core" }

    context "non-hierarchical relationship record" do
      let(:mapper){ "core_6-1-0_nonhierarchicalrelationship" }

      context "when all IDs found", vcr: "core_nhr_ids_found" do
        let(:datahash_path) {
          "spec/support/datahashes/core/nonHierarchicalRelationship1.json"
        }
        let(:mapped_pair){ handler.process(response) }

        context "with original data" do
          let(:mapped){ mapped_pair[0] }
          let(:fixture_path){ "core/nonHierarchicalRelationship1A.xml" }

          it "sets response id field as expected" do
            expect(mapped.identifier).to eq(
              "2020.1.107 TEST (collectionobjects) -> LOC2020.1.24 (movements)"
            )
          end

          it_behaves_like "Mapped"
        end

        context "with flipped data" do
          let(:mapped){ mapped_pair[1] }
          let(:fixture_path){ "core/nonHierarchicalRelationship1B.xml" }

          it "sets response id field as expected" do
            expect(mapped.identifier).to eq(
              "LOC2020.1.24 (movements) -> 2020.1.107 TEST (collectionobjects)"
            )
          end

          it_behaves_like "Mapped"
        end
      end

      # # @todo review whether this is even right, or whether this situation
      # #   should return an error
      context "when ID not found", vcr: "core_nhr_ids_not_found",
        skip: "Looks like wrong behavior" do
          let(:datahash_path) do
            "spec/support/datahashes/core/"\
              "nonHierarchicalRelationship2.json"
          end
          let(:mapped_pair){ handler.process(response) }

          context "with original data" do
            let(:mapped){ mapped_pair[0] }
            let(:fixture_path) { "core/nonHierarchicalRelationship2A.xml" }

            it "sets response id field as expected" do
              expect(mapped.identifier).to eq(
                "2020.1.107 TEST (collectionobjects) -> LOC MISSING (movements)"
              )
            end

            it_behaves_like "Mapped"
          end

          context "with flipped data" do
            let(:mapped){ mapped_pair[1] }
            let(:fixture_path) { "core/nonHierarchicalRelationship2B.xml" }

            it "sets response id field as expected" do
              expect(mapped.identifier).to eq(
                "LOC MISSING (movements) -> 2020.1.107 TEST (collectionobjects)"
              )
            end

            it_behaves_like "Mapped"
          end
        end
    end

    context "authority hierarchy record" do
      let(:mapper){ "core_6-1-0_authorityhierarchy" }

      vcr_opts = {
        cassette_name: "core_concept_cats_siamese",
        record: :new_episodes
      }
      context "with existing terms", vcr: vcr_opts do
        let(:datahash_path) {
          "spec/support/datahashes/core/authorityHierarchy1.json"
        }
        let(:fixture_path) { "core/authorityHierarchy1.xml" }

        it "sets response id field as expected" do
          expect(mapped.identifier).to eq("Cats > Siamese cats")
        end

        it_behaves_like "Mapped"
      end

      vcr_opts = {
        cassette_name: "core_concept_cats_tuxedo",
        record: :new_episodes
      }
      context "with a missing term", vcr: vcr_opts,
        skip: "should not attempt to map"  do
        let(:datahash_path) {
          "spec/support/datahashes/core/authorityHierarchy2.json"
        }
        let(:fixture_path) { "core/authorityHierarchy2.xml" }

        it "sets response id field as expected" do
          expect(mapped.identifier).to eq("Cats > Tuxedo cats")
        end

        it_behaves_like "Mapped"
      end
    end

    context "object hierarchy record" do
      let(:mapper){ "core_6-1-0_objecthierarchy" }

      context "with existing records", vcr: "core_oh_ids_found" do
        let(:datahash_path) {
          "spec/support/datahashes/core/objectHierarchy1.json"
        }
        let(:fixture_path) { "core/objectHierarchy1.xml" }

        it "sets response id field as expected" do
          expect(mapped.identifier).to eq("2020.1.105 > 2020.1.1055")
        end

        it_behaves_like "Mapped"
      end

      context "with missing record", skip: "should not attempt to map",
        vcr: "core_oh_ids_not_found" do
        let(:datahash_path) {
          "spec/support/datahashes/core/objectHierarchy2.json"
        }
        let(:fixture_path) { "core/objectHierarchy2.xml" }

        it_behaves_like "Mapped"

        it "sets response id field as expected" do
          expect(response.identifier).to eq("2020.1.105 > MISSING")
        end
      end
    end

    context "acquisition record", services_call: true do
      let(:mapper){ "core_6-1-0_acquisition" }

      context "record 1", vcr: "core_acq_1" do
        let(:datahash_path) {
          "spec/support/datahashes/core/acquisition1.json"
        }
        let(:fixture_path) { "core/acquisition1.xml" }

        it_behaves_like "Mapped"
      end

      context "record 2", vcr: "core_acq_2" do
        let(:datahash_path) {
          "spec/support/datahashes/core/acquisition2.json"
        }
        let(:fixture_path) { "core/acquisition2.xml" }

        it_behaves_like "Mapped"

        it "response has unparseable date error" do
          errors = mapped.errors
          expect(errors.length).to eq(1)
          err = errors.first
          ex_err = {
            category: :unparseable_date,
            field: "approvaldate",
            value: "1881-",
            message: "Unparseable date value in approvaldate: `1881-`"
          }
          expect(err).to eq(ex_err)
        end

        it "response has unparseable structured date warning" do
          warnings = mapped.warnings
          expect(warnings.length).to eq(1)
          wrn = warnings.first
          expect(wrn[:category]).to eq(:unparseable_structured_date)
          expect(wrn[:field]).to eq("acquisitiondategroup")
          expect(wrn[:value]).to eq("1881-")
        end
      end
    end

    context "collectionobject record" do
      let(:mapper){ "core_6-1-0_collectionobject" }

      context "record 1", vcr: "core_obj_1" do
        let(:datahash_path) {
          "spec/support/datahashes/core/collectionobject1.json"
        }
        let(:fixture_path) { "core/collectionobject1.xml" }

        it_behaves_like "Mapped"
      end

      context "record 4 (bomb and %NULLVALUE% terms)", vcr: "core_obj_4" do
        let(:datahash_path) {
          "spec/support/datahashes/core/collectionobject4.json"
        }
        let(:fixture_path) { "core/collectionobject4.xml" }

        it_behaves_like "MappedWithBlanks"
      end

      context "record 5 (%NULLVALUE% term in repeating group)",
        vcr: "core_obj_5" do
          let(:customcfg){ {delimiter: "|"} }
          let(:mapper){ "core_6-1-0_collectionobject" }
          let(:datahash_path) {
            "spec/support/datahashes/core/collectionobject5.json"
          }
          let(:fixture_path) { "core/collectionobject5.xml" }

          it_behaves_like "Mapped"
        end
    end

    context "conditioncheck record", services_call: true do
      let(:mapper){ "core_6-1-0_conditioncheck" }

      context "record 1", vcr: "core_cc_1" do
        let(:datahash_path) {
          "spec/support/datahashes/core/conditioncheck1.json"
        }
        let(:fixture_path) { "core/conditioncheck1.xml" }

        it_behaves_like "Mapped"
      end
    end

    context "conservation record", services_call: true do
      let(:mapper){ "core_6-1-0_conservation" }

      context "record 1", vcr: "core_ct_1" do
        let(:datahash_path) {
          "spec/support/datahashes/core/conservation1.json"
        }
        let(:fixture_path) { "core/conservation1.xml" }

        it_behaves_like "Mapped"
      end
    end

    context "exhibition record", services_call: true do
      let(:mapper){ "core_6-1-0_exhibition" }

      context "record 1", vcr: "core_exh_1" do
        let(:datahash_path) {
          "spec/support/datahashes/core/exhibition1.json"
        }
        let(:fixture_path) { "core/exhibition1.xml" }

        it_behaves_like "Mapped"
      end
    end

    context "group record" do
      let(:mapper){ "core_6-1-0_group" }

      context "record 1", vcr: "core_grp_1" do
        let(:datahash_path) { "spec/support/datahashes/core/group1.json" }
        let(:fixture_path) { "core/group1.xml" }

        it_behaves_like "Mapped"
      end
    end

    context "intake record" do
      let(:mapper){ "core_6-1-0_intake" }

      context "record 1", vcr: "core_int_1" do
        let(:datahash_path) { "spec/support/datahashes/core/intake1.json" }
        let(:fixture_path) { "core/intake1.xml" }

        it_behaves_like "Mapped"
      end
    end

    context "loanin record" do
      let(:mapper){ "core_6-1-0_loanin" }

      context "record 1", vcr: "core_li_1" do
        let(:datahash_path) { "spec/support/datahashes/core/loanin1.json" }
        let(:fixture_path) { "core/loanin1.xml" }

        it_behaves_like "Mapped"
      end
    end

    context "loanout record" do
      let(:mapper){ "core_6-1-0_loanout" }

      context "record 1", vcr: "core_lo_1" do
        let(:datahash_path) { "spec/support/datahashes/core/loanout1.json" }
        let(:fixture_path) { "core/loanout1.xml" }

        it_behaves_like "Mapped"
      end
    end

    context "movement record", vcr: "core_lmi_1" do
      let(:mapper){ "core_6-1-0_movement" }

      context "record 1" do
        let(:datahash_path) { "spec/support/datahashes/core/movement1.json" }
        let(:fixture_path) { "core/movement1.xml" }

        it_behaves_like "Mapped"
      end
    end

    context "media record" do
      let(:mapper){ "core_6-1-0_media" }

      context "record 1", vcr: "core_med_1" do
        let(:datahash_path) { "spec/support/datahashes/core/media1.json" }
        let(:fixture_path) { "core/media1.xml" }

        it_behaves_like "Mapped"
      end
    end

    context "objectexit record" do
      let(:mapper){ "core_6-1-0_objectexit" }

      context "record 1", vcr: "core_oe_1", skip: "funky default date value" do
        let(:datahash_path) {
          "spec/support/datahashes/core/objectexit1.json"
        }
        let(:fixture_path) { "core/objectexit1.xml" }

        # In previous test, where xpath is fixture xpath:
        #   TODO: - why is this next clause here?
        # next if xpath.start_with?(
        #   "/document/objectexit_common/exitDateGroup"
        # )

        it_behaves_like "Mapped"
      end
    end

    context "uoc record" do
      let(:mapper){ "core_6-1-0_uoc" }

      context "record 1", vcr: "core_uoc_1" do
        let(:datahash_path) { "spec/support/datahashes/core/uoc1.json" }
        let(:fixture_path) { "core/uoc1.xml" }

        it_behaves_like "Mapped"
      end
    end
  end
end

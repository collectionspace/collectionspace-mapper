# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::TermHandler do
  let(:client) { core_client }
  let(:termcache) { core_cache }
  let(:mapperpath) { 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_collectionobject.json' }
  let(:recmapper) { CS::Mapper::RecordMapper.new(mapper: File.read(mapperpath),
                                                 csclient: client,
                                                 termcache: termcache) }
  let(:colmapping) { recmapper.mappings.lookup(colname) }
  let(:th) { CS::Mapper::TermHandler.new(mapping: colmapping,
                                         data: data,
                                         client: client,
                                         cache: termcache,
                                         mapper: recmapper) }
 # before(:all) do
#    @config = @handler.mapper.batchconfig
  #  @ref_mapping = CollectionSpace::Mapper::ColumnMapping.new({
  #     :fieldname=>"reference",
  #     :transforms=>{:authority=>["citationauthorities", "citation"]},
  #     :source_type=>"authority",
  #     :namespace=>"collectionobjects_common",
  #     :xpath=>["referenceGroupList", "referenceGroup"],
  #     :data_type=>"string",
  #     :required=>"n",
  #     :repeats=>"n",
  #     :in_repeating_group=>"y",
  #     :opt_list_values=>[],
  #     :datacolumn=>"referencelocal",
  #     :fullpath=>"collectionobjects_common/referenceGroupList/referenceGroup"
  #   })
  #   @ttl_mapping =  CollectionSpace::Mapper::ColumnMapping.new({
  #     :fieldname=>"titleTranslationLanguage",
  #     :transforms=>{:vocabulary=>"languages"},
  #     :source_type=>"vocabulary",
  #     :namespace=>"collectionobjects_common",
  #     :xpath=>
  #     ["titleGroupList",
  #      "titleGroup",
  #      "titleTranslationSubGroupList",
  #      "titleTranslationSubGroup"],
  #     :data_type=>"string",
  #     :required=>"n",
  #     :repeats=>"n",
  #     :in_repeating_group=>"y",
  #     :opt_list_values=>[],
  #     :datacolumn=>"titletranslationlanguage",
  #     :fullpath=>
  #     "collectionobjects_common/titleGroupList/titleGroup/titleTranslationSubGroupList/titleTranslationSubGroup"
  #   })
  # end

  describe '#result' do
    context 'titletranslationlanguage (vocabulary, field subgroup)' do
      let(:colname) { 'titleTranslationLanguage' }
      let(:data) { [['%NULLVALUE%', 'Swahili'], ['Klingon', 'Spanish'], [CS::Mapper::THE_BOMB]] }

      it 'result is the transformed value for mapping' do
        expected = [['',
                     "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(swa)'Swahili'"],
                    ["urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(Klingon)'Klingon'",
                     "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(spa)'Spanish'"],
                   [CS::Mapper::THE_BOMB]]
        expect(th.result).to eq(expected)
      end
      it 'all values are refnames, blanks, or the bomb' do
        chk = th.result.flatten.select{ |v| v.start_with?('urn:') || v.empty? || v = CS::Mapper::THE_BOMB }
        expect(chk.length).to eq(5)
      end
    end

    context 'reference (authority, field group)' do
      let(:colname) { 'referenceLocal' }
      let(:data) { ['Reference 1', 'Reference 2', '%NULLVALUE%'] }
      
      it 'result is the transformed value for mapping' do
        expected = [
          "urn:cspace:core.collectionspace.org:citationauthorities:name(citation):item:name(Reference11143445083)'Reference 1'",
          "urn:cspace:core.collectionspace.org:citationauthorities:name(citation):item:name(Reference22573957271)'Reference 2'",
          ''
          ]
        expect(th.result).to eq(expected)
      end
      it 'all values are refnames' do
        chk = th.result.flatten.select{ |v| v.start_with?('urn:') }
        expect(chk.length).to eq(2)
      end
    end
    end
  
  describe '#terms' do
    context 'titletranslationlanguage (vocabulary, field subgroup)' do
      let(:colname) { 'titleTranslationLanguage' }
      let(:data) { [['%NULLVALUE%', 'Swahili'], ['Sanza', 'Spanish'], [CS::Mapper::THE_BOMB]] }

      it 'contains a term Hash for each value' do
        expect(th.terms.length).to eq(3)
      end
      it 'term hash :found == true when term exists already' do
        chk = th.terms.select{ |h| h[:found] }
        expect(chk.length).to eq(2)
      end
      it 'term hash :found == false when term does not exist already' do
        chk = th.terms.select{ |h| !h[:found] }
        expect(chk.first[:refname].display_name).to eq('Sanza')
      end
    end

    context 'reference (authority, field group)' do
      let(:colname) { 'referenceLocal' }
      let(:data) { ['Reference 3', 'Reference 3', 'Reference 4', '%NULLVALUE%'] }
      
      it 'contains a term Hash for each value' do
        expect(th.terms.length).to eq(3)
      end
      it 'term hash :found == true when term exists already' do
        chk = th.terms.select{ |h| h[:found] }
        expect(chk.length).to eq(1)
      end
      it 'term hash :found == false when term does not exist already' do
        chk = th.terms.select{ |h| !h[:found] }
        expect(chk.first[:refname].display_name).to eq('Reference 3')
      end
    end
  end
end

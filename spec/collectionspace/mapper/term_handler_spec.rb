# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::TermHandler do
  let(:client){ core_client }
  let(:termcache){ core_cache }
  let(:csidcache){ core_csid_cache }
  let(:mapperpath){ 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_collectionobject.json' }
  let(:recmapper) do
    CollectionSpace::Mapper::RecordMapper.new(mapper: File.read(mapperpath),
                                 csclient: client,
                                 termcache: termcache,
                                 csidcache: csidcache)
  end
  let(:colmapping){ recmapper.mappings.lookup(colname) }
  let(:searcher){ CollectionSpace::Mapper::Searcher.new(client: client)}
  let(:th) do
    CollectionSpace::Mapper::TermHandler.new(mapping: colmapping,
                                data: data,
                                client: client,
                                mapper: recmapper,
                                searcher: searcher
                               )
  end
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
      let(:colname){ 'titleTranslationLanguage' }
      let(:data){ [['%NULLVALUE%', 'Swahili'], %w[Klingon Spanish], [CollectionSpace::Mapper::THE_BOMB]] }

      it 'result is the transformed value for mapping' do
        expected = [['',
                     "urn:cspace:c.core.collectionspace.org:vocabularies:name(languages):item:name(swa)'Swahili'"],
                    ['',
                     "urn:cspace:c.core.collectionspace.org:vocabularies:name(languages):item:name(spa)'Spanish'"],
                    [CollectionSpace::Mapper::THE_BOMB]]
        expect(th.result).to eq(expected)
      end
    end

    context 'reference (authority, field group)' do
      let(:colname){ 'referenceLocal' }
      let(:data){ ['Arthur', 'Harding', '%NULLVALUE%'] }

      it 'result is the transformed value for mapping' do
        expected = [
          "urn:cspace:c.core.collectionspace.org:citationauthorities:name(citation):item:name(Arthur62605812848)'Arthur'",
          "urn:cspace:c.core.collectionspace.org:citationauthorities:name(citation):item:name(Harding2510592089)'Harding'",
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
    let(:terms){ th.terms }
    context 'titletranslationlanguage (vocabulary, field subgroup)' do
      let(:colname){ 'titleTranslationLanguage' }
      let(:data){ [['%NULLVALUE%', 'Swahili'], %w[Sanza Spanish], [CollectionSpace::Mapper::THE_BOMB]] }

      context 'when new term (Sanza) is initially encountered' do
        it 'returns terms as expected' do
          found = terms.select{ |h| h[:found] }
          not_found = terms.select{ |h| !h[:found] }
          expect(terms.length).to eq(3)
          expect(found.length).to eq(2)
          expect(not_found.first[:refname].urn).to eq('vocabularies|||languages|||Sanza')
        end
      end

      context 'when new term is subsequently encountered' do
        it 'the term is still treated as not found' do
          first_handler = CollectionSpace::Mapper::TermHandler.new(mapping: colmapping,
                                                      data: data,
                                                      client: client,
                                                      mapper: recmapper,
                                                      searcher: searcher
                                                     )

          chk = terms.select{ |h| h[:found] }
          expect(chk.length).to eq(2)
        end
      end
    end

    context 'reference (authority, field group)' do
      let(:colname){ 'referenceLocal' }
      let(:data){ ['Reference 3', 'Reference 3', 'Reference 4', '%NULLVALUE%'] }

      context 'when new term (Reference 3) is initially encountered' do
        it 'contains a term Hash for each value' do
          found = th.terms.select{ |h| h[:found] }
          not_found = th.terms.select{ |h| !h[:found] }
          expect(terms.length).to eq(3)
          expect(found.length).to eq(0)
          expect(not_found.first[:refname].display_name).to eq('Reference 3')
        end
      end
    end
  end
end

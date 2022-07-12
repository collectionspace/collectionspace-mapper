# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::Dates do
  let(:client){ anthro_client }
  let(:cache){ anthro_cache }
  let(:csid_cache){ anthro_csid_cache }
  let(:config){ CollectionSpace::Mapper::Config.new }
  let(:searcher) { CollectionSpace::Mapper::Searcher.new(client: client, config: config) }
  let(:handler) do
    CollectionSpace::Mapper::Dates::StructuredDateHandler.new(
      client: client,
      cache: cache,
      csid_cache: csid_cache,
      config: config,
      searcher: searcher
    )
  end
  
  describe CollectionSpace::Mapper::Tools::Dates::CspaceDate do
    let(:csdate){ CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string, handler) }

    context 'with one digit month' do
      let(:date_string){ '2019-5-20' }

      it 'parses as expected' do
        expect(csdate.mappable['dateEarliestScalarValue']).to start_with('2019-05-20')
        expect(csdate.mappable['dateDisplayDate']).to eq(date_string)
      end
    end
    
    
    context 'when date string is Chronic parseable (e.g. 2020-09-30)' do
      let(:date_string){ '2020-09-30' }
      
      it '.mappable dateDisplayDate = 2020-09-30' do
        expect(csdate.mappable['dateDisplayDate']).to eq('2020-09-30')
      end

      it '.mappable dateEarliestSingleYear = 2020' do
        expect(csdate.mappable['dateEarliestSingleYear']).to eq('2020')
      end

      it '.mappable dateEarliestSingleMonth = 9' do
        expect(csdate.mappable['dateEarliestSingleMonth']).to eq('9')
      end

      it '.mappable dateEarliestSingleDay = 30' do
        expect(csdate.mappable['dateEarliestSingleDay']).to eq('30')
      end

      it '.mappable dateEarliestSingleEra = refname for CE' do
        expect(csdate.mappable['dateEarliestSingleEra']).to eq("urn:cspace:c.anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'")
      end

      it '.mappable dateEarliestScalarValue = 2020-09-30T00:00:00.000Z' do
        expect(csdate.mappable['dateEarliestScalarValue']).to eq('2020-09-30T00:00:00.000Z')
      end

      it '.mappable dateLatestScalarValue = 2020-10-01T00:00:00.000Z' do
        expect(csdate.mappable['dateLatestScalarValue']).to eq('2020-10-01T00:00:00.000Z')
      end

      context 'when date format is ambiguous re: month/date order (e.g. 1/2/2020)' do
        let(:date_string){ '1/2/2020' }

        context 'when no date_format specified in config' do
          it 'defaults to M/D/Y interpretation' do
            expect(csdate.mappable['dateEarliestScalarValue']).to start_with('2020-01-02')
          end
        end

        context 'when date_format in config = day month year' do
          let(:config){ CollectionSpace::Mapper::Config.new(config: {date_format: 'day month year'}) }
          
          it 'interprets as D/M/Y' do
            expect(csdate.mappable['dateEarliestScalarValue']).to start_with('2020-02-01')
          end
        end
      end
    end

    context 'when date string has two-digit year (e.g. 9/19/91)' do
      let(:date_string){ '9/19/91' }

      context 'when config[:two_digit_year_handling] = coerce' do
        it 'Chronic parses date with coerced 4-digit year' do
          expect(csdate.mappable['dateEarliestSingleYear']).to eq('1991')
        end
      end

      context 'when config[:two_digit_year_handling] = literal', services_call: true do
        let(:config){ CollectionSpace::Mapper::Config.new(config: {two_digit_year_handling: 'literal'}) }

        it 'Services parses date with uncoerced 2-digit year' do
          expect(csdate.mappable['dateEarliestSingleYear']).to eq('91')
        end
      end
    end

    context 'when date string is not Chronic parseable (e.g. 1/2/2000 - 12/21/2001)', services_call: true do
      let(:date_string){ '1/2/2000 - 12/21/2001' }

      it '.timestamp will be nil' do
        expect(csdate.timestamp).to be_nil
      end

      it '.mappable is populated by hash from cspace-services' do
        expect(csdate.mappable).to be_a(Hash)
      end

      it 'ambiguous dates are interpreted as M/D/Y regardless of config settings' do
        expect(csdate.mappable['dateEarliestSingleMonth']).to eq('1')
      end
    end

    context 'when date string is not Chronic or services parseable', services_call: true do
      context 'date = VIII.XIV.MMXX' do
        let(:date_string){ 'VIII.XIV.MMXX' }

        it '.timestamp will be nil' do
          expect(csdate.timestamp).to be_nil
        end

        it '.mappable is populated by hash' do
          expect(csdate.mappable).to be_a(Hash)
        end

        it 'dateDisplayDate = the unparseable string' do
          expect(csdate.mappable['dateDisplayDate']).to eq('VIII.XIV.MMXX')
        end

        it 'scalarValuesComputed = false' do
          expect(csdate.mappable['scalarValuesComputed']).to eq('false')
        end
      end
    end

    context 'when date string is Chronic parseable but we want services parsing', services_call: true do
      context 'when date string = march 2020' do
        let(:date_string){ 'march 2020' }

        it 'dateEarliestScalarValue = 2020-03-01T00:00:00.000Z' do
          expect(csdate.mappable['dateEarliestScalarValue']).to eq('2020-03-01T00:00:00.000Z')
        end

        it 'dateLatestScalarValue = 2020-04-01T00:00:00.000Z' do
          expect(csdate.mappable['dateLatestScalarValue']).to eq('2020-04-01T00:00:00.000Z')
        end

        it 'dateEarliestSingleMonth = 3' do
          expect(csdate.mappable['dateEarliestSingleMonth']).to eq('3')
        end

        it 'dateLatestMonth = 3' do
          expect(csdate.mappable['dateLatestMonth']).to eq('3')
        end

        it 'dateEarliestSingleDay = 1' do
          expect(csdate.mappable['dateEarliestSingleDay']).to eq('1')
        end

        it 'dateLatestDay = 31' do
          expect(csdate.mappable['dateLatestDay']).to eq('31')
        end

        it 'dateEarliestSingleYear = 2020' do
          expect(csdate.mappable['dateEarliestSingleYear']).to eq('2020')
        end

        it 'dateLatestYear = 2020' do
          expect(csdate.mappable['dateLatestYear']).to eq('2020')
        end
      end

      context 'when date string = 2020-03' do
        let(:date_string){ '2020-03' }

        it 'dateEarliestScalarValue = 2020-03-01T00:00:00.000Z' do
          expect(csdate.mappable['dateEarliestScalarValue']).to eq('2020-03-01T00:00:00.000Z')
        end

        it 'dateLatestScalarValue = 2020-04-01T00:00:00.000Z' do
          expect(csdate.mappable['dateLatestScalarValue']).to eq('2020-04-01T00:00:00.000Z')
        end

        it 'dateEarliestSingleMonth = 3' do
          expect(csdate.mappable['dateEarliestSingleMonth']).to eq('3')
        end

        it 'dateLatestMonth = 3' do
          expect(csdate.mappable['dateLatestMonth']).to eq('3')
        end

        it 'dateEarliestSingleDay = 1' do
          expect(csdate.mappable['dateEarliestSingleDay']).to eq('1')
        end

        it 'dateLatestDay = 31' do
          expect(csdate.mappable['dateLatestDay']).to eq('31')
        end

        it 'dateEarliestSingleYear = 2020' do
          expect(csdate.mappable['dateEarliestSingleYear']).to eq('2020')
        end

        it 'dateLatestYear = 2020' do
          expect(csdate.mappable['dateLatestYear']).to eq('2020')
        end
      end

      context 'when date string = 2002' do
        let(:date_string){ '2002' }

        it 'dateEarliestScalarValue = 2002-01-01T00:00:00.000Z' do
          expect(csdate.mappable['dateEarliestScalarValue']).to eq('2002-01-01T00:00:00.000Z')
        end

        it 'dateLatestScalarValue = 2003-01-01T00:00:00.000Z' do
          expect(csdate.mappable['dateLatestScalarValue']).to eq('2003-01-01T00:00:00.000Z')
        end

        it 'dateEarliestSingleMonth = 1' do
          expect(csdate.mappable['dateEarliestSingleMonth']).to eq('1')
        end

        it 'dateLatestMonth = 12' do
          expect(csdate.mappable['dateLatestMonth']).to eq('12')
        end

        it 'dateEarliestSingleDay = 1' do
          expect(csdate.mappable['dateEarliestSingleDay']).to eq('1')
        end

        it 'dateLatestDay = 31' do
          expect(csdate.mappable['dateLatestDay']).to eq('31')
        end

        it 'dateEarliestSingleYear = 2002' do
          expect(csdate.mappable['dateEarliestSingleYear']).to eq('2002')
        end

        it 'dateLatestYear = 2002' do
          expect(csdate.mappable['dateLatestYear']).to eq('2002')
        end
      end
    end
  end
end

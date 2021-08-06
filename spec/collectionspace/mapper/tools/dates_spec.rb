# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::Dates do
  before(:all) do
    @client = anthro_client
    @cache = anthro_cache
    @config = CS::Mapper::Config.new
  end

  describe CollectionSpace::Mapper::Tools::Dates::CspaceDate do
    context 'when date string is Chronic parseable (e.g. 2020-08-14)' do
      before(:all) do
        @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new('2020-09-30', @client, @cache, @config)
      end

      it 'populates .timestamp' do
        res = @res.timestamp.to_s
        expect(res).to start_with('2020-09-30 12:00:00')
      end

      it '.mappable dateDisplayDate = 2020-09-30' do
        res = @res.mappable['dateDisplayDate']
        expect(res).to eq('2020-09-30')
      end

      it '.mappable dateEarliestSingleYear = 2020' do
        res = @res.mappable['dateEarliestSingleYear']
        expect(res).to eq('2020')
      end

      it '.mappable dateEarliestSingleMonth = 9' do
        res = @res.mappable['dateEarliestSingleMonth']
        expect(res).to eq('9')
      end

      it '.mappable dateEarliestSingleDay = 30' do
        res = @res.mappable['dateEarliestSingleDay']
        expect(res).to eq('30')
      end

      it '.mappable dateEarliestSingleEra = refname for CE' do
        res = @res.mappable['dateEarliestSingleEra']
        expect(res).to eq("urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'")
      end

      it '.mappable dateEarliestScalarValue = 2020-09-30T00:00:00.000Z' do
        res = @res.mappable['dateEarliestScalarValue']
        expect(res).to eq('2020-09-30T00:00:00.000Z')
      end

      it '.mappable dateLatestScalarValue = 2020-10-01T00:00:00.000Z' do
        res = @res.mappable['dateLatestScalarValue']
        expect(res).to eq('2020-10-01T00:00:00.000Z')
      end

      context 'when date format is ambiguous re: month/date order (e.g. 1/2/2020)' do
        before(:all) do
          @string = '1/2/2020'
        end

        context 'when no date_format specified in config' do
          it 'defaults to M/D/Y interpretation' do
            res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache,
                                                                        @config).timestamp.to_s
            expect(res).to start_with('2020-01-02 12:00:00')
          end
        end
        context 'when date_format in config = month day year' do
          it 'interprets as M/D/Y' do
            res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache,
                                                                        @config).timestamp.to_s
            expect(res).to start_with('2020-01-02 12:00:00')
          end
        end
        context 'when date_format in config = day month year' do
          it 'interprets as D/M/Y' do
            config = CS::Mapper::Config.new(config: {date_format: 'day month year'})
            res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache, config).timestamp.to_s
            expect(res).to start_with('2020-02-01 12:00:00')
          end
        end
      end
    end

    context 'when date string has two-digit year (e.g. 9/19/91)' do
      before(:all) do
        @string = '9/19/91'
      end

      context 'when config[:two_digit_year_handling] = coerce' do
        before(:all) do
          @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache, @config)
        end

        it 'Chronic parses date with coerced 4-digit year' do
          expect(@res.timestamp.to_s).to start_with('1991-09-19')
        end
      end

      context 'when config[:two_digit_year_handling] = literal', services_call: true do
        before(:all) do
          config = CS::Mapper::Config.new(config: {two_digit_year_handling: 'literal'})
          @res = CS::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache, config)
        end

        it 'Services parses date with uncoerced 2-digit year' do
          expect(@res.mappable['dateEarliestSingleYear']).to eq('91')
        end
      end
    end

    context 'when date string is not Chronic parseable (e.g. 1/2/2000 - 12/21/2001)', services_call: true do
      before(:all) do
        @string = '1/2/2000 - 12/21/2001'
        @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache, @config)
      end

      it '.timestamp will be nil' do
        res = @res.timestamp
        expect(res).to be_nil
      end

      it '.mappable is populated by hash from cspace-services' do
        res = @res.mappable
        expect(res).to be_a(Hash)
      end

      it 'ambiguous dates are interpreted as M/D/Y regardless of config settings' do
        expect(@res.mappable['dateEarliestSingleMonth']).to eq('1')
      end
    end

    context 'when date string is not Chronic or services parseable', services_call: true do
      context 'date = VIII.XIV.MMXX' do
        before(:all) do
          @string = 'VIII.XIV.MMXX'
          @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache, @config)
        end

        it '.timestamp will be nil' do
          res = @res.timestamp
          expect(res).to be_nil
        end

        it '.mappable is populated by hash' do
          res = @res.mappable
          expect(res).to be_a(Hash)
        end

        it 'dateDisplayDate = the unparseable string' do
          expect(@res.mappable['dateDisplayDate']).to eq('VIII.XIV.MMXX')
        end

        it 'scalarValuesComputed = false' do
          expect(@res.mappable['scalarValuesComputed']).to eq('false')
        end
      end
    end

    context 'when date string is Chronic parseable but we want services parsing', services_call: true do
      context 'when date string = march 2020' do
        before(:all) do
          @string = 'march 2020'
          @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache, @config)
        end

        it 'dateEarliestScalarValue = 2020-03-01T00:00:00.000Z' do
          expect(@res.mappable['dateEarliestScalarValue']).to eq('2020-03-01T00:00:00.000Z')
        end

        it 'dateLatestScalarValue = 2020-04-01T00:00:00.000Z' do
          expect(@res.mappable['dateLatestScalarValue']).to eq('2020-04-01T00:00:00.000Z')
        end

        it 'dateEarliestSingleMonth = 3' do
          expect(@res.mappable['dateEarliestSingleMonth']).to eq('3')
        end

        it 'dateLatestMonth = 3' do
          expect(@res.mappable['dateLatestMonth']).to eq('3')
        end

        it 'dateEarliestSingleDay = 1' do
          expect(@res.mappable['dateEarliestSingleDay']).to eq('1')
        end

        it 'dateLatestDay = 31' do
          expect(@res.mappable['dateLatestDay']).to eq('31')
        end

        it 'dateEarliestSingleYear = 2020' do
          expect(@res.mappable['dateEarliestSingleYear']).to eq('2020')
        end

        it 'dateLatestYear = 2020' do
          expect(@res.mappable['dateLatestYear']).to eq('2020')
        end
      end

      context 'when date string = 2020-03' do
        before(:all) do
          @string = '2020-03'
          @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache, @config)
        end

        it 'dateEarliestScalarValue = 2020-03-01T00:00:00.000Z' do
          expect(@res.mappable['dateEarliestScalarValue']).to eq('2020-03-01T00:00:00.000Z')
        end

        it 'dateLatestScalarValue = 2020-04-01T00:00:00.000Z' do
          expect(@res.mappable['dateLatestScalarValue']).to eq('2020-04-01T00:00:00.000Z')
        end

        it 'dateEarliestSingleMonth = 3' do
          expect(@res.mappable['dateEarliestSingleMonth']).to eq('3')
        end

        it 'dateLatestMonth = 3' do
          expect(@res.mappable['dateLatestMonth']).to eq('3')
        end

        it 'dateEarliestSingleDay = 1' do
          expect(@res.mappable['dateEarliestSingleDay']).to eq('1')
        end

        it 'dateLatestDay = 31' do
          expect(@res.mappable['dateLatestDay']).to eq('31')
        end

        it 'dateEarliestSingleYear = 2020' do
          expect(@res.mappable['dateEarliestSingleYear']).to eq('2020')
        end

        it 'dateLatestYear = 2020' do
          expect(@res.mappable['dateLatestYear']).to eq('2020')
        end
      end

      context 'when date string = 2002' do
        before(:all) do
          @string = '2002'
          @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache, @config)
        end

        it 'dateEarliestScalarValue = 2002-01-01T00:00:00.000Z' do
          expect(@res.mappable['dateEarliestScalarValue']).to eq('2002-01-01T00:00:00.000Z')
        end

        it 'dateLatestScalarValue = 2003-01-01T00:00:00.000Z' do
          expect(@res.mappable['dateLatestScalarValue']).to eq('2003-01-01T00:00:00.000Z')
        end

        it 'dateEarliestSingleMonth = 1' do
          expect(@res.mappable['dateEarliestSingleMonth']).to eq('1')
        end

        it 'dateLatestMonth = 12' do
          expect(@res.mappable['dateLatestMonth']).to eq('12')
        end

        it 'dateEarliestSingleDay = 1' do
          expect(@res.mappable['dateEarliestSingleDay']).to eq('1')
        end

        it 'dateLatestDay = 31' do
          expect(@res.mappable['dateLatestDay']).to eq('31')
        end

        it 'dateEarliestSingleYear = 2002' do
          expect(@res.mappable['dateEarliestSingleYear']).to eq('2002')
        end

        it 'dateLatestYear = 2002' do
          expect(@res.mappable['dateLatestYear']).to eq('2002')
        end
      end
    end
  end
end

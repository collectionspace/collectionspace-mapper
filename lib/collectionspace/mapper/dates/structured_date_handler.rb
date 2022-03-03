# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class StructuredDateHandler
        include CollectionSpace::Mapper::TermSearchable

        attr_reader :client, :cache, :config
        
        # @param client [CollectionSpace::Client]
        # @param cache [CollectionSpace::RefCache]
        # @param config [CollectionSpace::Mapper::Config]
        def initialize(client:, cache:, csid_cache:, config:)
          @client = client
          @cache = cache
          @csid_cache = csid_cache
          @config = config
        end

        def ce
          @ce ||= get_ce
        end

        def call(date_string)
          if date_string == '%NULLVALUE%'
            CS::Mapper::Dates::NullDate.new
          elsif date_string == THE_BOMB
            CS::Mapper::Dates::DateBomber.new
          elsif date_formats.any?{ |re| date_string.match?(re) }
            CS::Mapper::Dates::ChronicParser.new(date_string, self)
          elsif two_digit_year_date_formats.any?{ |re| date_string.match?(re) }
            CS::Mapper::Dates::TwoDigitYearHandler.new(date_string, self)
          elsif service_parseable_month_formats.any?{ |re| date_string.match?(re) }
            CS::Mapper::Dates::ServicesParser.new(date_string, self)
          elsif other_month_formats.any?{ |re| date_string.match?(re) }
            CS::Mapper::Dates::YearMonthDateCreator.new(date_string, self)
          elsif date_string.match?(/^\d{4}$/)
            CS::Mapper::Dates::YearDateCreator.new(date_string, self)
          else
            CS::Mapper::Dates::ServicesParser.new(date_string, self)
          end
        end

        def timestamp_suffix
          'T00:00:00.000Z'
        end

        private
        
        # @todo memowise this and other methods?
        def date_formats
          @date_formats ||= [
            '^\d{1,2}[-\/]\d{1,2}[-\/]\d{4}$', # 02-15-2020, 2-15-2020, 2/15/2020, 02/15/2020
            '^\d{4}-\d{1,2}-\d{2}$', # 2020-02-15
            '^\w+ \d{1,2},? \d{4}$', # Feb 15 2020, February 15, 2020
            '^\d{1,2} \w+ \d{4}$' # 15 Feb 2020, 15 February 2020
          ].map{ |f| Regexp.new(f) }
        end

        def get_ce
          cached = cached_term('CE', 'vocabularies', 'dateera')
          @ce = cached
          return cached if cached

          searched = searched_term('CE', :refname, 'vocabularies', 'dateera')
          @ce = searched
          searched
        end

        def two_digit_year_date_formats
          @two_digit_year_date_formats ||= [
            '^\d{1,2}[-\/]\d{1,2}[-\/]\d{2}$'
          ].map{ |f| Regexp.new(f) }
        end

        def service_parseable_month_formats
          @service_parseable_month_formats ||= [
            '^\w+ \d{4}$',
            '^\d{4} \w+$'
          ].map{ |f| Regexp.new(f) }
        end
        
        def other_month_formats
          @other_month_formats ||= [
            '^\d{4}-\d{2}$',
            '^\d{1,2}[-\/]\d{4}$'
          ].map{ |f| Regexp.new(f) }
        end
      end
    end
  end
end


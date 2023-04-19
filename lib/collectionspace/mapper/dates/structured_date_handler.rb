# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class StructuredDateHandler
        include CollectionSpace::Mapper::TermSearchable

        # @param handler [CollectionSpace::Mapper::DataHandler]
        def initialize(handler)
          @handler = handler
          handler.config.date_handler = self
        end

        def ce
          @ce ||= get_ce
        end

        def call(date_string)
          if date_string.blank? || date_string == "%NULLVALUE%"
            CollectionSpace::Mapper::Dates::NullDate.new
          elsif date_string == CollectionSpace::Mapper.bomb
            CollectionSpace::Mapper::Dates::DateBomber.new
          elsif date_formats.any? { |re| date_string.match?(re) }
            CollectionSpace::Mapper::Dates::ChronicParser.new(
              date_string,
              handler
            )
          elsif two_digit_year_date_formats.any? { |re| date_string.match?(re) }
            CollectionSpace::Mapper::Dates::TwoDigitYearHandler.new(
              date_string,
              handler
            )
          elsif service_parseable_month_formats.any? { |re|
                  date_string.match?(re)
                }
            CollectionSpace::Mapper::Dates::ServicesParser.new(
              date_string,
              handler
            )
          elsif other_month_formats.any? { |re| date_string.match?(re) }
            CollectionSpace::Mapper::Dates::YearMonthDateCreator.new(
              date_string,
              handler
            )
          elsif date_string.match?(/^\d{1,4}$/)
            CollectionSpace::Mapper::Dates::YearDateCreator.new(
              date_string,
              handler
            )
          else
            CollectionSpace::Mapper::Dates::ServicesParser.new(
              date_string,
              handler
            )
          end
        end

        private

        attr_reader :handler

        # @todo memowise this and other methods?
        def date_formats
          @date_formats ||= [
            # 02-15-2020, 2-15-2020, 2/15/2020, 02/15/2020
            '^\d{1,2}[-\/]\d{1,2}[-\/]\d{4}$',
            # 2020-02-15
            '^\d{4}-\d{1,2}-\d{2}$',
            # Feb 15 2020, February 15, 2020
            '^\w+ \d{1,2},? \d{4}$',
            # 15 Feb 2020, 15 February 2020
            '^\d{1,2} \w+ \d{4}$'
          ].map { |f| Regexp.new(f) }
        end

        def get_ce
          cached = cached_term("CE", "vocabularies", "dateera")
          @ce = cached
          return cached if cached

          searched = searched_term("CE", :refname, "vocabularies", "dateera")
          @ce = searched
          searched
        end

        def two_digit_year_date_formats
          @two_digit_year_date_formats ||= [
            '^\d{1,2}[-\/]\d{1,2}[-\/]\d{2}$'
          ].map { |f| Regexp.new(f) }
        end

        def service_parseable_month_formats
          @service_parseable_month_formats ||= [
            '^\w+ \d{4}$',
            '^\d{4} \w+$'
          ].map { |f| Regexp.new(f) }
        end

        def other_month_formats
          @other_month_formats ||= [
            '^\d{4}-\d{2}$',
            '^\d{1,2}[-\/]\d{4}$'
          ].map { |f| Regexp.new(f) }
        end
      end
    end
  end
end

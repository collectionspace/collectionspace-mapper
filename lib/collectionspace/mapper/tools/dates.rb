# frozen_string_literal: true

require 'chronic'
require 'facets/date'
require 'facets/time'

module CollectionSpace
  module Mapper
    module Tools
      module Dates
        extend self

        class CspaceDate
          TIMESTAMP_SUFFIX = 'T00:00:00.000Z'
          attr_reader :date_string, :client, :config,
            :parsed_date, :mappable, :warnings,
            :timestamp, :stamp

          def initialize(date_string, client, config)
            @date_string = date_string
            @client = client
            @config = CollectionSpace::Mapper::Tools::Config.new(config).date_config
            
            @mappable = {}
            @warnings = []
            @ce = "urn:cspace:#{client.domain}:vocabularies:name(dateera):item:name(ce)'CE'"

            process

            old_processing if mappable.empty?
          end

          def process
            return if date_string == '%NULLVALUE%'
            
            @parsed_date = Emendate.parse(date_string, config)

            if parsing_errors?
              warnings << "Cannot process date: #{date_string}. Passing it through as dateDisplayDate with no scalar values"
              passthrough_display_date
              end
          end

          def passthrough_display_date
            @mappable = {"dateDisplayDate"=>date_string,
                         "scalarValuesComputed"=>"false"}
          end
          
          def parsing_errors?
            parsed_date.errors.empty? ? false : true
          end
          
          def old_processing

            date_formats = [
              '^\d{1,2}[-\/]\d{1,2}[-\/]\d{4}$', #02-15-2020, 2-15-2020, 2/15/2020, 02/15/2020
              '^\d{4}-\d{2}-\d{2}$', #2020-02-15
              '^\w+ \d{1,2},? \d{4}$', #Feb 15 2020, February 15, 2020
              '^\d{1,2} \w+ \d{4}$' #15 Feb 2020, 15 February 2020
            ].map{ |f| Regexp.new(f) }

            two_digit_year_date_formats = [
              '^\d{1,2}[-\/]\d{1,2}[-\/]\d{2}$'
            ].map{ |f| Regexp.new(f) }
            
            service_parseable_month_formats = [
              '^\w+ \d{4}$',
              '^\d{4} \w+$',
            ].map{ |f| Regexp.new(f) }

            other_month_formats = [
              '^\d{4}-\d{2}$',
              '^\d{1,2}[-\/]\d{4}$'
            ].map{ |f| Regexp.new(f) }

            if date_string == '%NULLVALUE%'
              
            elsif
              date_formats.any?{ |re| @date_string.match?(re) }
              try_chronic_parse(@date_string)
              @timestamp ? create_mappable_date : try_services_query
            elsif two_digit_year_date_formats.any?{ |re| @date_string.match?(re) }
              if @config[:two_digit_year_handling] == 'literal'
                try_services_query
              else
                try_chronic_parse(coerced_year_date)
                @timestamp ? create_mappable_date : try_services_query
              end
            elsif service_parseable_month_formats.any?{ |re| @date_string.match?(re) }
              try_services_query
            elsif other_month_formats.any?{ |re| @date_string.match?(re) }
              create_mappable_month
            elsif @date_string.match?(/^\d{4}$/)
              create_mappable_year
            else
              try_services_query
            end

            stamp = @mappable.fetch('dateEarliestScalarValue', nil)
            @stamp = stamp.blank? ? @date_string : stamp
          end
          
          def coerced_year_date
            val = @date_string.gsub('/', '-').split('-')
            yr = val.pop
            this_year = Time.now.year.to_s
            this_year_century = this_year[0,2]
            this_year_last_two = this_year[2,2].to_i

            if yr.to_i > this_year_last_two
              val <<  "#{this_year_century.to_i - 1}#{yr}"
            else
              val << "#{this_year_century}#{yr}"
            end
            val.join('-')
          end
          
          def try_chronic_parse(string)
            if @config[:date_format] == 'day month year'
              @timestamp = Chronic.parse(string, endian_precedence: :little)
            else
              @timestamp = Chronic.parse(string)
            end
          end
          
          def create_mappable_date
            date = @timestamp.to_date
            next_day = date + 1
            
            @mappable['dateDisplayDate'] = @date_string
            @mappable['dateEarliestSingleYear'] = date.year.to_s
            @mappable['dateEarliestSingleMonth'] = date.month.to_s
            @mappable['dateEarliestSingleDay'] = date.day.to_s
            @mappable['dateEarliestSingleEra'] = @ce
            @mappable['dateEarliestScalarValue'] = "#{date.stamp(:db)}#{TIMESTAMP_SUFFIX}"
            @mappable['dateLatestScalarValue'] = "#{next_day.stamp(:db)}#{TIMESTAMP_SUFFIX}"
            @mappable['scalarValuesComputed'] = 'true'
          end

          def create_mappable_month
            year = @date_string.match(/(\d{4})/)[1].to_i
            month = @date_string.sub(year.to_s, '').match(/(\d{1,2})/)[1].to_i
            next_month = month + 1
            last_day_of_month = Date.new(year, month, -1).day
            
            @mappable['dateDisplayDate'] = @date_string
            @mappable['dateEarliestSingleYear'] = year.to_s
            @mappable['dateEarliestSingleMonth'] = month.to_s
            @mappable['dateEarliestSingleDay'] = '1'
            @mappable['dateEarliestSingleEra'] = @ce
            @mappable['dateLatestYear'] = year.to_s
            @mappable['dateLatestMonth'] = month.to_s
            @mappable['dateLatestDay'] = last_day_of_month.to_s
            @mappable['dateLatestEra'] = @ce
            @mappable['dateEarliestScalarValue'] = "#{year}-#{month.to_s.rjust(2, '0')}-01#{TIMESTAMP_SUFFIX}"
            @mappable['dateLatestScalarValue'] = "#{year}-#{next_month.to_s.rjust(2, '0')}-01#{TIMESTAMP_SUFFIX}"
            @mappable['scalarValuesComputed'] = 'true'
          end

          def create_mappable_year
            year = @date_string
            next_year = @date_string.to_i + 1
            
            @mappable['dateDisplayDate'] = @date_string
            @mappable['dateEarliestSingleYear'] = year
            @mappable['dateEarliestSingleMonth'] = '1'
            @mappable['dateEarliestSingleDay'] = '1'
            @mappable['dateEarliestSingleEra'] = @ce
            @mappable['dateLatestYear'] = year
            @mappable['dateLatestMonth'] = '12'
            @mappable['dateLatestDay'] = '31'
            @mappable['dateLatestEra'] = @ce
            @mappable['dateEarliestScalarValue'] = "#{year}-01-01#{TIMESTAMP_SUFFIX}"
            @mappable['dateLatestScalarValue'] = "#{next_year}-01-01#{TIMESTAMP_SUFFIX}"
            @mappable['scalarValuesComputed'] = 'true'
          end

          def try_services_query
            sdquery = "structureddates?displayDate=#{date_string}"
            response = client.get(sdquery)
            if response.status_code == 200
              result = response.result['structureddate_common']
              @mappable = fix_services_scalars(result)
            end
          end

          def fix_services_scalars(services_result)
            new_hash = {}
            services_result.each do |k, v|
              if k.end_with?('ScalarValue')
                new_hash[k] = "#{v}#{TIMESTAMP_SUFFIX}"
              else
                new_hash[k] = v
              end
            end
            new_hash
          end

          def map(doc, parentnode, groupname)
            @parser_result.each do |datefield, value|
              value = DateTime.parse(value).iso8601(3).sub('+00:00', "Z") if datefield['ScalarValue']
            end
          end
        end
      end
    end
  end
end

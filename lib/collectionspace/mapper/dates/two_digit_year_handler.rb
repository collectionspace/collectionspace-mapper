# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class TwoDigitYearHandler
        include CS::Mapper::Dates::Mappable

        attr_reader :mappable
        
        def initialize(date_string, handler)
          @date_string = date_string
          @year_handling = handler.config.two_digit_year_handling

          if literal?
            @mappable = CS::Mapper::Dates::ServicesParser.new(date_string, handler).mappable
          elsif coerce?
            mappable = CS::Mapper::Dates::ChronicParser.new(coerced_year_date, handler).mappable
            mappable['dateDisplayDate'] = date_string
            @mappable = mappable
          else
            @mappable = no_mappable_date
          end
          self
        end

        private
        
        attr_reader :date_string, :year_handling

        def coerce?
          year_handling == 'coerce'
        end

        def coerced_year_date
          val = date_string.gsub('/', '-').split('-')
          yr = val.pop
          this_year = Time.now.year.to_s
          this_year_century = this_year[0, 2]
          this_year_last_two = this_year[2, 2].to_i

          val << if yr.to_i > this_year_last_two
                   "#{this_year_century.to_i - 1}#{yr}"
                 else
                   "#{this_year_century}#{yr}"
                 end
          val.join('-')
        end

        def literal?
          year_handling == 'literal'
        end
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class DateBomber
        attr_reader :mappable, :stamp
        def initialize
          @bomb = CollectionSpace::Mapper.bomb
          @fields = CollectionSpace::Mapper.structured_date_detailed_fields
        end

        def mappable
          fields.map{ |field| [field, bomb]}
            .to_h
        end

        def stamp
          bomb
        end

        private

        attr_reader :bomb, :fields
      end
    end
  end
end

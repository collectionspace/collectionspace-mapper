# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Dates
      class ServicesParser
        include CS::Mapper::Dates::Mappable
        
        attr_reader :mappable
        def initialize(date_string, handler)
          @date_string = date_string
          @handler = handler
          @mappable = parse
          self
        end

        private        
        
        attr_reader :date_string, :handler

        def fix_services_scalars(services_result)
          new_hash = {}
          services_result.each do |k, v|
            new_hash[k] = if k.end_with?('ScalarValue')
                            "#{v}#{handler.timestamp_suffix}"
                          else
                            v
                          end
          end
          new_hash
        end

        def get_response
          handler.client.get("structureddates?displayDate=#{date_string}")
        rescue
          nil
        end
        
        def parse
          response = get_response
          return no_mappable_date unless response

          if response.status_code == 200
            result = response.result['structureddate_common']
            fix_services_scalars(result)
          else
            no_mappable_date
          end
        end
      end
    end
  end
end


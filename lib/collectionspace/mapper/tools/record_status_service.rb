# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class MultipleCsRecordsFoundError < StandardError
      attr_reader :message

      def initialize(count)
        @message = "#{count} matching records found in CollectionSpace. Cannot determine which to update."
      end
    end

    class NoClientServiceError < StandardError; end

    module Tools
      class RecordStatusService
        def initialize(client, mapper)
          @client = client
          @mapper = mapper
          @is_authority = @mapper.config.service_type == 'authority'
          service = get_service
          @search_field = @is_authority ? service[:term] : service[:field]
          @ns_prefix = service[:ns_prefix]
          @path = service[:path]
          @response_top = @client.get_list_types(@path)[0]
          @response_nested = @client.get_list_types(@path)[1]
        end

        def call(response)
          value = get_value_for_record_status(response)

          begin
            searchresult = lookup(value)
          rescue CollectionSpace::Mapper::MultipleCsRecordsFoundError => e
            err = {
              category: :multiple_matching_recs,
              field: @mapper.config.search_field,
              type: nil,
              subtype: nil,
              value: value,
              message: e.message
            }
            response.errors << err
          else
            status = searchresult[:status]
            response.record_status = status
            return if status == :new

            response.csid = searchresult[:csid]
            response.uri = searchresult[:uri]
            response.refname = searchresult[:refname]
            num_found = searchresult[:multiple_recs_found]
            return unless num_found

            response.add_multi_rec_found_warning(num_found)
          end
        end
        
        private
        
        # if there are failures in looking up records due to parentheses, single/double
        #  quotes, special characters, etc., this should be resolved in the
        #  collectionspace-client code.
        # Tests in examples/search.rb
        def lookup(value)
          response = if @ns_prefix == 'relations'
                       @client.find_relation(subject_csid: value[:sub], object_csid: value[:obj])
                     else
                       lookup_non_relationship(value)
                     end

          ct = count_results(response)
          if ct == 0
            reportable_result
          elsif ct == 1
            reportable_result(response.parsed[@response_top][@response_nested])
          elsif ct > 1
            raise CollectionSpace::Mapper::MultipleCsRecordsFoundError, ct unless use_first?

            item = response.parsed[@response_top][@response_nested].first
            num_found = response.parsed[@response_top][@response_nested].length
            reportable_result(item).merge({multiple_recs_found: num_found})
          end
        end


        def get_value_for_record_status(response)
          case @mapper.service_type.to_s
          when 'CollectionSpace::Mapper::Relationship'
            {
              sub: response.combined_data['relations_common']['subjectCsid'][0],
              obj: response.combined_data['relations_common']['objectCsid'][0]
            }
          when 'CollectionSpace::Mapper::Authority'
            response.split_data['termdisplayname'].first
          else
            response.identifier
          end
        end
        

        def reportable_result(item = nil)
          return {status: :new} unless item

          {
            status: :existing,
            csid: item['csid'],
            uri: item['uri'],
            refname: item['refName']
          }
        end

        def lookup_non_relationship(value)
          @client.find(
            type: @mapper.config.service_path,
            subtype: @mapper.config.authority_subtype,
            value: value,
            field: @search_field
          )
        end

        def use_first?
          return true if @mapper.batchconfig.multiple_recs_found == 'use_first'

          false
        end

        def count_results(response)
          raise CollectionSpace::RequestError, response.result.body unless response.result.success?

          response.parsed[@response_top]['totalItems'].to_i
        end

        def get_service
          if @is_authority
            begin
              @client.service(
                type: @mapper.config.authority_type,
                subtype: @mapper.config.authority_subtype
              )
            rescue KeyError
              raise CS::Mapper::NoClientServiceError,
                    "#{@mapper.config.authority_type} > #{@mapper.config.authority_subtype}"
            end
          else
            begin
              @client.service(type: @mapper.config.service_path)
            rescue KeyError
              raise CS::Mapper::NoClientServiceError, @mapper.config.service_path
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # given a RecordMapper hash and a data hash, returns CollectionSpace XML document
    class DataMapper
      ::DataMapper = CollectionSpace::Mapper::DataMapper
      attr_reader :mapper, :cache, :docs, :errors, :warnings, :newterms
      def initialize(record_mapper:, cache:)
        @mapper = record_mapper
        @cache = cache
        @docs = {}
        @errors = []
        @warnings = []
        @newterms = []
        
      end

      def process(data_hash)
        v = RecordValidator.new(record_mapper: @mapper,
                                        cache: @cache,
                                        data: data_hash
                                       )
        
      end
      
      private
      
      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.document {
            @mapper.keys.each do |ns|
              xml.send(ns){
                process_group(xml, [ns])
              }
            end
          }
        end
        Nokogiri::XML(builder.to_xml)
      end

      def process_group(xml, grouppath)
        @mapper.dig(*grouppath).keys.each do |key|
          thispath = grouppath.clone.append(key)
          case key
          when :fieldmappings
            write_fields(xml, thispath)
          else
            xml.send(key){
              process_group(xml, thispath)
            }
          end
        end
      end
      
      def write_fields(xml, path)
        @mapper.dig(*path).each do |mapping|
          val = get_value(mapping[:datacolumn])
          xml.send(mapping[:fieldname], val) unless val.nil? || val.empty?
        end
      end

      def get_value(column)
        @data.fetch(column, nil)
      end
    end
  end
end

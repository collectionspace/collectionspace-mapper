# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # The XML document structure for a given record type.
    # Knows the structure as a Hash provided by initial JSON record mapper
    #
    # Produces a blank XML document with all namespace and field group elements
    #   populated so mapper may populate data via xpath
    class XmlTemplate
      class << self
        def call(...)
          new(...)
        end
      end

      # @param docstructure [Hash] section from JSON record mapper
      def initialize(docstructure)
        @docstructure = docstructure
        @xml = build_xml
      end

      def doc
        xml.dup
      end

      private

      attr_reader :docstructure, :xml

      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.document { create_record_namespace_nodes(xml) }
        end
        Nokogiri::XML(builder.to_xml)
      end

      def create_record_namespace_nodes(xml)
        docstructure.keys.each do |namespace|
          xml.send(namespace) do
            process_group(xml, [namespace])
          end
        end
      end

      def process_group(xml, grouppath)
        docstructure.dig(*grouppath).keys.each do |key|
          thispath = grouppath.clone.append(key)

          # Send the key with an underscore on the end to keep element
          #   names that are also ruby keywords/method names, like
          #   "methods", from being treated as such
          xml.send(:"#{key}_") do
            process_group(xml, thispath)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # The XML document structure for a given record type.
    # Knows the structure as a Hash provided by initial JSON record mapper
    # Provides a blank XML document with all namespace and field group elements
    #  populated so mapper may populate data via xpath
    class XmlTemplate
      def initialize(docstructure)
        @docstructure = docstructure
      end

      def blankdoc
        build_xml
      end

      private

      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.document { create_record_namespace_nodes(xml) }
        end
        Nokogiri::XML(builder.to_xml)
      end

      def create_record_namespace_nodes(xml)
        @docstructure.keys.each do |namespace|
          xml.send(namespace) do
            process_group(xml, [namespace])
          end
        end
      end

      def process_group(xml, grouppath)
        @docstructure.dig(*grouppath).keys.each do |key|
          thispath = grouppath.clone.append(key)
          xml.send(key) do
            process_group(xml, thispath)
          end
        end
      end
    end
  end
end

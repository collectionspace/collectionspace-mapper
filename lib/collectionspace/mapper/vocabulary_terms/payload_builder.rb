# frozen_string_literal: true

require "dry/monads"

module CollectionSpace
  module Mapper
    module VocabularyTerms
      KNOWN_OPT_FIELDS = %w[description source sourcePage termStatus].freeze

      # Sets up a class with client context, that can process terms from
      #   multiple vocabularies
      class PayloadBuilder
        extend Dry::Monads[:result]

        # @param mode [:add, :update]
        # @param domain [String] CS client domain
        # @param csid [String] CSID of vocabulary
        # @param name [String] machine name of vocabulary
        # @param term [String] to be created
        # @param term_data [Hash{String=>String}] contains shortIdentifier for
        #   new terms, and shortIdentifier and refName for existing terms
        # @param opt_fields [nil, Hash]
        def self.call(mode:, domain:, csid:, name:, term:, term_data:,
          opt_fields: nil)
          # rubocop:disable Layout/LineLength
          base_string = <<~XML
            <?xml version="1.0" encoding="utf-8" standalone="yes"?>
            <document name="vocabularyitems">
                <ns2:vocabularyitems_common
                   xmlns:ns2="http://collectionspace.org/services/vocabulary"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                   <inAuthority>#{csid}</inAuthority>
                   <shortIdentifier>#{term_data["shortIdentifier"]}</shortIdentifier>
                </ns2:vocabularyitems_common>
            </document>
          XML
          # rubocop:enable Layout/LineLength

          doc = Nokogiri.parse(base_string, "UTF-8")
          namespaces = {
            "ns2" => "http://collectionspace.org/services/vocabulary"
          }
          ns = doc.xpath("//document/ns2:vocabularyitems_common", namespaces)
            .first
          add_refname(doc, ns, term_data, domain, name, term)
          valid_opt_fields(opt_fields).merge({"displayName" => term})
            .each { |key, val| add_element(key, val, doc, ns) }
          CollectionSpace::Mapper.defuse_bomb(doc)
          Success(doc.to_xml)
        end

        def self.add_refname(doc, ns, term_data, domain, name, term)
          node = Nokogiri::XML::Node.new("refName", doc)
          node.content = if term_data.key?("refName")
            term_data["refName"]
          else
            "urn:cspace:#{domain}:vocabularies:name(#{name}):item:"\
              "name(#{term_data["shortIdentifier"]})'#{term}'"
          end
          ns.add_child(node)
        end

        def self.valid_opt_fields(opt_fields)
          return {} unless opt_fields

          keep_fields = opt_fields.select do |key, val|
            KNOWN_OPT_FIELDS.include?(key)
          end
          return {} if keep_fields.empty?

          keep_fields
        end
        private_class_method :valid_opt_fields

        def self.add_element(key, val, doc, ns)
          node = Nokogiri::XML::Node.new(key, doc)
          node.content = val
          ns.add_child(node)
        end
        private_class_method :add_element
      end
    end
  end
end

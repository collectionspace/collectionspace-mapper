# frozen_string_literal: true

require "dry/monads"

module CollectionSpace
  module Mapper
    module VocabularyTerms
      ADD_OPT_FIELDS = %w[
        description source sourcePage termStatus
      ].freeze
      UPDATE_OPT_FIELDS = (ADD_OPT_FIELDS + ["displayName"]).freeze

      # Sets up a class with client context, that can process terms from
      #   multiple vocabularies
      class PayloadBuilder
        extend Dry::Monads[:result, :do]

        # @param mode [:add, :update]
        # @param domain [String] CS client domain
        # @param csid [String] CSID of vocabulary
        # @param name [String] machine name of vocabulary
        # @param term [String] to be created
        # @param term_data [Hash{String=>String}] contains shortIdentifier and
        #   possibly other data in the future
        # @param opt_fields [Hash]
        def self.call(mode:, domain:, csid:, name:, term:, term_data:,
          opt_fields: {})
          _chk = yield validate_opt_fields(mode, opt_fields)
          opt_fields = case_enforce_opt_fields(opt_fields)

          displayname = if opt_fields.key?("displayName")
            opt_fields["displayName"]
          else
            opt_fields&.merge!({"displayName" => term})
            term
          end

          base_string = case mode
          when :add then add_base(csid, term_data)
          when :update then update_base(term_data)
          end

          doc = Nokogiri.parse(base_string, "UTF-8")
          namespaces = {
            "ns2" => "http://collectionspace.org/services/vocabulary"
          }
          ns = doc.xpath("//document/ns2:vocabularyitems_common", namespaces)
            .first
          add_refname(doc, ns, term_data, domain, name, displayname)
          opt_fields.each { |key, val| add_element(key, val, doc, ns) }
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

        def self.validate_opt_fields(mode, opt_fields)
          return Success() unless opt_fields

          known = case mode
          when :add then ADD_OPT_FIELDS.dup
          when :update then UPDATE_OPT_FIELDS.dup
          end
          chk = opt_fields.keys.map!(&:downcase) - known.map!(&:downcase)
          return Success() if chk.empty?

          msgfields = chk.map do |f|
            opt_fields.keys.find do |k|
              k.downcase == f
            end
          end
          msg = "Invalid optional field(s) provided for vocabulary term "\
            "#{mode}: #{msgfields.join(", ")}"

          Failure(msg)
        end
        private_class_method :validate_opt_fields

        def self.case_enforce_opt_fields(opt_fields)
          opt_fields.transform_keys do |key|
            if key == "sourcepage"
              "sourcePage"
            elsif key == "termstatus"
              "termStatus"
            elsif key == "displayname"
              "displayName"
            else
              key
            end
          end
        end
        private_class_method :case_enforce_opt_fields

        def self.add_base(csid, term_data)
          # rubocop:disable Layout/LineLength
          <<~XML
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
        end
        private_class_method :add_base

        def self.update_base(term_data)
          <<~XML
            <?xml version="1.0" encoding="utf-8" standalone="yes"?>
            <document name="vocabularyitems">
                <ns2:vocabularyitems_common
                   xmlns:ns2="http://collectionspace.org/services/vocabulary"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                   <shortIdentifier>#{term_data["shortIdentifier"]}</shortIdentifier>
                </ns2:vocabularyitems_common>
            </document>
          XML
          # rubocop:enable Layout/LineLength
        end
        private_class_method :update_base

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

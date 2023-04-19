# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      class RefName
        class << self
          def from_urn(urn)
            parsed = parse(urn)
            new(
              type: parsed[:type],
              subtype: parsed[:subtype],
              display_name: parsed[:label],
              identifier: parsed[:identifier],
              urn: urn
            )
          end

          def from_term(source_type:, type:, subtype:, term:, handler:)
            identifier = set_identifier(source_type, term)
            new(
              type: type,
              subtype: subtype,
              display_name: term,
              identifier: identifier,
              urn: "urn:cspace:#{handler.domain}:#{type}:name(#{subtype}):"\
                "item:name(#{identifier})'#{term}'"
            )
          end

          private

          def parse(urn)
            CollectionSpace::RefName.parse(urn)
          rescue
            fail CollectionSpace::Mapper::UnparseableRefNameUrnError.new(urn)
          end

          def set_identifier(type, term)
            id_class(type).call(term)
          end

          def id_class(type)
            if type == :authority
              CollectionSpace::Mapper::Identifiers::AuthorityShortIdentifier
            else
              CollectionSpace::Mapper::Identifiers::ShortIdentifier
            end
          end
        end

        attr_reader :type, :subtype, :identifier, :display_name, :urn

        def initialize(type:, subtype:, display_name:, identifier:, urn:)
          @type = type
          @subtype = subtype
          @display_name = display_name || ""
          @identifier = identifier
          @urn = urn
        end

        def key
          "#{type}-#{subtype}-#{display_name}"
        end
      end
    end
  end
end

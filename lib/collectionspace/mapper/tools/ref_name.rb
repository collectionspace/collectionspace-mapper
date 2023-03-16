# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      class RefNameArgumentError < ArgumentError
        def initialize(
          msg = "Arguments requires either :urn OR :source_type, :type, "\
            ":subtype, :term, :cache values"
        )
          super
        end
      end

      class UnparseableUrnError < CollectionSpace::Mapper::Error; end

      class RefName
        attr_reader :domain, :type, :subtype, :identifier, :display_name, :urn

        def initialize(args)
          term_args = %i[source_type type subtype term cache].sort
          urn_args = %i[urn]
          args_given = args.keys.sort

          if args_given == urn_args
            @urn = args[:urn]
            new_from_urn
          elsif args_given == term_args
            cache = args[:cache]
            @domain = cache.domain.sub(%r{https?://}, "").sub(
              "/cspace-services", ""
            )
            @type = args[:type]
            @subtype = args[:subtype]
            @display_name = args[:term]
            if args[:source_type] == :authority
              new_from_authority_term
            else
              new_from_term
            end
            @urn = build_urn
          else
            raise RefNameArgumentError
          end
        end

        def key
          "#{type}-#{subtype}-#{display_name}"
        end

        private

        def build_urn
          "urn:cspace:#{@domain}:#{@type}:name(#{@subtype}):item:name"\
            "(#{@identifier})'#{@display_name}'"
        end

        def new_from_term
          @identifier =
            CollectionSpace::Mapper::Identifiers::ShortIdentifier.new(
              term: @display_name
            ).value
        end

        def new_from_authority_term
          @identifier =
            CollectionSpace::Mapper::Identifiers::AuthorityShortIdentifier.new(
              term: @display_name
            ).value
        end

        # rubocop:disable Layout/LineLength
        def new_from_urn
          if /^urn:cspace:([^:]+):([^:]+):name\(([^)]+)\):item:name\(([^)]+)\)'/.match?(@urn)
            term_parts_from_urn
          elsif /^urn:cspace:([^:]+):([^:]+):id\(([^)]+)\)(.*)/.match?(@urn)
            non_term_parts_from_urn
          else
            raise UnparseableUrnError.new("Tried to parse: #{@urn}")
          end
        end
        # rubocop:enable Layout/LineLength

        def term_parts_from_urn
          parts = @urn.match(
            /^urn:cspace:([^:]+):([^:]+):name\(([^)]+)\):item:name\(([^)]+)\)'/
          )
          @domain = parts[1]
          @type = parts[2]
          @subtype = parts[3]
          @identifier = parts[4]
          @display_name = @urn.match(/item:name\(.+\)'(.+)'$/)[1]
        end

        def non_term_parts_from_urn
          parts = @urn.match(/^urn:cspace:([^:]+):([^:]+):id\(([^)]+)\)(.*)/)
          @domain = parts[1]
          @type = parts[2]
          @subtype = nil
          @identifier = parts[3]
          @display_name = parts[4].delete("'") if parts[4]
        end
      end
    end
  end
end

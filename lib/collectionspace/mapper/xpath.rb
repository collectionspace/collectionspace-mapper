# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class Xpath
      attr_reader :path, :mappings

      # @param path [String] the xpath represented
      # @param mappings [Array<CollectionSpace::Mapper::ColumnMapping] for
      #   fields that are direct children of the xpath
      # @param handler [CollectionSpace::Mapper::DataHandler]
      def initialize(path:, mappings:, handler:)
        @path = path
        @mappings = mappings
        @handler = handler
        @rectype = handler.record.recordtype
        @xpaths = handler.record.xpaths
      end

      def to_s
        "<##{self.class}:#{object_id.to_s(8)}\n"\
          "profile: #{handler.record.profile_basename}\n"\
          "version: #{handler.record.version}\n"\
          "rectype: #{handler.record.recordtype}\n"\
          "#{for_recordtype.map { |xp| "  #{xp}" }.join("\n")}"\
          ">"
      end
      alias_method :inspect, :to_s

      def children
        @children ||= set_children
      end

      def dup
        self.class.new(
          path: path,
          mappings: mappings.map(&:dup),
          handler: handler
        )
      end

      # @param keep [Array<String>] datacolumn values to keep
      def for_row(keep)
        keeping = mappings.select { |mapping| keep.any?(mapping.datacolumn) }

        # these mappings were needed to get data in via template for processing,
        #   but do not actually get used to produce XML
        if rectype == "nonhierarchicalrelationship"
          keeping = keeping.reject do |mapping|
            %w[subjectType objectType].any?(mapping.fieldname)
          end
        end
        if %w[authorityhierarchy objecthierarchy].any?(rectype)
          keeping = keeping.reject do |mapping|
            %w[termType termSubType].any?(mapping.fieldname)
          end
        end

        self.class.new(
          path: path,
          mappings: keeping,
          handler: handler
        )
      end

      def is_group?
        @is_group ||= set_is_group
      end

      def is_subgroup?
        @is_subgroup ||= set_is_subgroup
      end

      def parent
        @parent ||= set_parent
      end

      def subgroups
        @subgroups ||= set_subgroups
      end

      private

      attr_reader :handler, :rectype, :xpaths

      def set_children
        set = xpaths.list
          .select { |xpath| xpath.start_with?(path) }
        set - [path]
      end

      def set_is_group
        fieldct = mappings.map(&:fieldname).uniq.length
        clumps = mappings.group_by(&:in_repeating_group)
        case clumps.keys.sort.join(" -- ")
        when ""
          true
        when "n/a"
          false
        when "y"
          true
        when "n"
          false
        when "as part of larger repeating group"
          if fieldct == 1 && mappings[0].repeats == "y"
            true
          else
            fail(
              CollectionSpace::Mapper::UnrecognizedGroupPatternError,
              self
            )
          end
        else
          fail(
            CollectionSpace::Mapper::UnrecognizedGroupPatternError,
            self
          )
        end
      end

      def set_is_subgroup
        return false if xpaths.subgroups
          .none?(path)

        true
      end

      def set_parent
        return "" unless path["/"]

        set = xpaths.list
          .select { |xpath| path.start_with?(xpath) }
          .sort_by(&:length)
          .reverse

        set.shift
        set.empty? ? "" : set[0]
      end

      def set_subgroups
        return [] if children.empty? || parent.empty?

        children
      end
    end
  end
end

# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class Xpath

      attr_reader :path, :mappings

      def initialize(path:, mappings:)
        @path = path
        @mappings = mappings
      end

      def to_s
        "<##{self.class}:#{object_id.to_s(8)}\n"\
          "profile: #{CollectionSpace::Mapper.record.profile_basename}\n"\
          "version: #{CollectionSpace::Mapper.record.version}\n"\
          "rectype: #{CollectionSpace::Mapper.record.recordtype}\n"\
          "#{for_recordtype.map{ |xp| "  #{xp}" }.join("\n")}"\
          ">"
      end
      alias_method :inspect, :to_s

      def children
        @children ||= set_children
      end

      def dup
        self.class.new(
          path: path,
          mappings: mappings.map(&:dup)
          )
      end

      # @param keep [Array<String>] datacolumn values to keep
      def for_row(keep)
        keeping = mappings.select{ |mapping| keep.any?(mapping.datacolumn) }

        rectype = CollectionSpace::Mapper.record.recordtype
        # these mappings were needed to get data in via template for processing,
        #   but do not actually get used to produce XML
        if rectype == 'nonhierarchicalrelationship'
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
          mappings: keeping
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

      def set_children
        set = CollectionSpace::Mapper.record.xpaths
          .list
          .select{ |xpath| xpath.start_with?(path) }
        set - [path]
      end

      def set_is_group
        fieldct = mappings.map(&:fieldname).uniq.length
        clumps = mappings.group_by(&:in_repeating_group)
        case clumps.keys.sort.join(' -- ')
        when ''
          true
        when 'n/a'
          false
        when 'y'
          true
        when 'n'
          false
        when "as part of larger repeating group"
          if fieldct == 1 && mappings[0].repeats == 'y'
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
        return false if CollectionSpace::Mapper.record.xpaths
          .subgroups
          .none?(path)

        true
      end

      def set_parent
        return "" unless path["/"]

        set = CollectionSpace::Mapper.record.xpaths
          .list
          .select{ |xpath| path.start_with?(xpath) }
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

# pry(#<RSpec::ExampleGroups::CollectionSpaceMapperXpaths::Hash::WithCoreCollectionobhect>)> rt = ms.select{ |m| m['fieldname'] == 'rightType' }
# => [{"fieldname"=>"rightType",
#   "transforms"=>{:vocabulary=>"rightstype"},
#   "source_type"=>"vocabulary",
#   "source_name"=>"rightstype",
#   "namespace"=>"collectionobjects_common",
#   "xpath"=>["rightsGroupList", "rightsGroup"],
#   "data_type"=>"string",
#   "repeats"=>"n",
#   "in_repeating_group"=>"y",
#   "opt_list_values"=>[],
#   "datacolumn"=>"rightType",
#   "required"=>"n"},
#  {"fieldname"=>"rightType",
#   "transforms"=>{},
#   "source_type"=>"refname",
#   "source_name"=>"rightstype",
#   "namespace"=>"collectionobjects_common",
#   "xpath"=>["rightsGroupList", "rightsGroup"],
#   "data_type"=>"csrefname",
#   "repeats"=>"n",
#   "in_repeating_group"=>"y",
#   "opt_list_values"=>[],
#   "datacolumn"=>"rightTypeRefname",
#   "required"=>"n"}]

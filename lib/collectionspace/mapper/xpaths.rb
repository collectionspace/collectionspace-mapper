# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class Xpaths
      include Enumerable

      attr_reader :hash

      # @param handler [CollectionSpace::Mapper::DataHandler]
      def initialize(handler)
        handler.config.record.xpaths = self
        @handler = handler
        @mappings = handler.record.mappings
        @hash = create_xpaths
        self
      end

      def dup
        hash.map{ |path, xpath| [path, xpath.dup] }
          .to_h
      end

      def each(&block)
        hash.each{ |key, value| block.call(key, value) }
      end

      # @param data [Hash]
      def for_row(data)
        keep = data.keys.map(&:downcase) + ['shortidentifier']
        result = dup.map{ |path, xpath| [path, xpath.for_row(keep)] }
          .to_h
          .reject{ |_path, xpath| xpath.mappings.empty? }
        result
      end

      def to_s
        "<##{self.class}:#{object_id.to_s(8)}\n"\
          "profile: #{handler.record.profile_basename}\n"\
          "version: #{handler.record.version}\n"\
          "rectype: #{handler.record.recordtype}\n"\
          "#{for_recordtype.map{ |xp| "  #{xp}" }.join("\n")}"\
          ">"
      end
      alias_method :inspect, :to_s

      def list
        hash.keys.sort
      end

      def lookup(xpath)
        hash[xpath]
      end

      def subgroups
        @subgroups ||= set_subgroups
      end

      private

      attr_reader :handler, :mappings

      def create_xpaths
        mappings.group_by{ |mapping| mapping.fullpath }
          .map{|xpath, maps|
            [xpath, CollectionSpace::Mapper::Xpath.new(
              path: xpath,
              mappings: maps,
              handler: handler
            )]
          }.to_h
      end

      def set_subgroups
        hash.values
          .map(&:subgroups)
          .flatten
          .sort
          .uniq
      end
    end
  end
end

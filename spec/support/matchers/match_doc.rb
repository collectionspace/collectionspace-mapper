# frozen_string_literal: true

require "spec_helper"
module MatchDocMatcher
  class MatchDocMatcher
    def initialize(fixture_path, handler, mode: :normal, blanks: :drop)
      delblank = blanks == :drop
      @fixture_doc = get_xml_fixture(fixture_path, delblank)
      @fixture_xpaths = test_xpaths(fixture_doc, handler.record.mappings)
      @mode = mode
      @blanks = blanks
    end

    def matches?(mapped_doc)
      @mapped_doc = mapped_doc
      @mapped_xpaths = list_xpaths(mapped_doc)

      has_expected_values? && lacks_extra_xpaths? && has_all_xpaths?
    end

    def failure_message
      sections = []

      unless has_all_xpaths?
        sections << [
          "XPATHS IN FIXTURE BUT NOT RESULT:\n",
          output_format(missing_xpaths)
        ].join("")
      end

      unless lacks_extra_xpaths?
        sections << [
          "XPATHS IN RESULT BUT NOT FIXTURE:\n",
          output_format(unexpected_xpaths)
        ].join("")
      end

      unless has_expected_values?
        sections << [
          "UNEXPECTED VALUES IN SHARED XPATHS:\n",
          unexpected_val_output
        ].join("")
      end

      if mode == :verbose
        puts mapped_doc
      end

      sections.join("\n\n")
    end

    def failure_message_when_negated
      "Trying to test this is chaos. Please stop."
    end

    private

    attr_reader :fixture_doc, :fixture_xpaths, :mode, :blanks,
      :mapped_doc, :mapped_xpaths

    def output_format(hash)
      hash.map { |xpath, val| "  #{xpath}\n    #{val}" }
        .join("\n")
    end

    def has_expected_values?
      unexpected_vals.empty?
    end

    def lacks_extra_xpaths?
      unexpected_xpaths.empty?
    end

    def has_all_xpaths?
      missing_xpaths.empty?
    end

    # Expected xpath, but non-matching value for the xpath
    def unexpected_vals
      @unexpected_vals ||= mapped_vals.reject do |xpath, val|
        !fixture_vals.key?(xpath) || # Exclude unexpected xpaths
          fixture_vals[xpath] == val # and matching values
      end
    end

    def unexpected_val_output
      unexpected_vals.map do |xpath, val|
        "  #{xpath}\n"\
          "    Expected: #{fixture_vals[xpath]}\n"\
          "    Got     : #{val}"
      end.join("\n")
    end

    # Xpaths populated in mapped doc, but not fixture doc
    def unexpected_xpaths
      @unexpected_xpaths ||= mapped_vals.reject do |xpath, _val|
        fixture_vals.key?(xpath)
      end
    end

    # Xpaths populated in fixture doc, but not mapped doc
    def missing_xpaths
      @missing_xpaths ||= fixture_vals.reject do |xpath, _val|
        mapped_vals.key?(xpath)
      end
    end

    def fixture_vals
      @fixture_vals ||= fixture_xpaths.map do |xpath|
        [xpath, standardize_value(fixture_doc.xpath(xpath).text)]
      end.to_h
    end

    def mapped_vals
      @mapped_vals ||= fixture_xpaths.map do |xpath|
        [xpath, standardize_value(mapped_doc.xpath(xpath).text)]
      end.to_h
    end

    # The way CollectionSpace uses different URIs for the same namespace prefix
    #   in the same document is irregular and makes it impossible to query a
    #   document via xpath if the namespaces are defined. For testing, remove
    #   them...
    def remove_namespaces(doc)
      doc = doc.clone
      doc.remove_namespaces!
      doc.xpath("/*/*").each { |n| n.name = n.name.sub("ns2:", "") }
      doc
    end

    def remove_blank_structured_dates(doc)
      doc.traverse do |node|
        # CSpace saves empty structured date fields with only a
        #   scalarValuesComputed value of false, but we don't want to compare
        #   against these empty nodes
        node.remove if node.name["Date"] && node.text == "false"
      end
      doc
    end

    def get_xml_fixture(filename, remove_blanks = true)
      doc = remove_namespaces(
        Nokogiri::XML(
          File.read("spec/support/xml/#{filename}")
        ) do |c|
          c.noblanks
        end
      )
      doc = remove_blank_structured_dates(doc)

      # fields to omit from testing across the board
      rejectfields = %w[computedCurrentLocation].sort
      doc.traverse do |node|
        # Drop empty nodes
        node.remove if remove_blanks && !node.text.match?(/\S/m)
        # Drop sections of the document we don't write with the mapper
        if node.name == "collectionspace_core" ||
            node.name == "account_permission"
          node.remove
        end
        # Drop fields created by CS application
        node.remove if rejectfields.bsearch { |f| f == node.name }
      end
      doc
    end

    def get_xpaths(doc)
      xpaths = []
      doc.traverse { |node| xpaths << node.path }
      xpaths.sort!
    end

    # removes paths for nodes in hierarchy that do not have their own values
    # @param xpaths [Array<String>]
    def field_value_xpaths(xpaths)
      xpaths.reject do |path|
        this_ind = xpaths.find_index(path)
        next_ind = this_ind + 1
        next_path = xpaths[next_ind]
        next_path&.start_with?(path)
      end
    end

    # returns array of just the most specific xpaths from cleaned fixture XML
    #   for testing removes fields not included in the RecordMapper mappings
    #   (which may be set in the XML due to weird default stuff in the
    #   application/services layer, but don't need to be in mapped XML)
    #
    # testdoc should be the result of calling get_xml_fixture
    def test_xpaths(testdoc, mappings)
      xpaths = list_xpaths(testdoc)
      mapper_defined_paths(xpaths, mappings)
    end

    def mapper_defined_paths(xpaths, mappings)
      mappaths = mappings.map do |mapping|
        "/document/#{mapping.fullpath}/#{mapping.fieldname}"
      end

      xpaths.select do |path|
        path = remove_xpath_occurrence_indicators(path)
        mappaths.any? { |e| path.start_with?(e) }
      end
    end

    def remove_xpath_occurrence_indicators(path)
      path.match(%r{^(.*)/})[1].gsub(/\[\d+\]/, "")
    end

    def list_xpaths(doc)
      xpaths = get_xpaths(doc)
      field_value_xpaths(xpaths)
    end

    def standardize_value(string)
      if string.start_with?("urn:cspace")
        string.sub(/(item:name\([a-zA-Z]+)\d+(\)')/, '\1\2')
      else
        string
      end
    end
  end

  def match_doc(doc, handler, mode: :normal, blanks: :drop)
    MatchDocMatcher.new(doc, handler, mode: mode, blanks: blanks)
  end
end

RSpec.configure do |config|
  config.include MatchDocMatcher
end

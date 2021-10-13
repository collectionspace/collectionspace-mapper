# frozen_string_literal: true

require 'memo_wise'

module Helpers
  prepend MemoWise
  extend self

  require_relative './anthro_helpers'
  require_relative './bonsai_helpers'
  require_relative './botgarden_helpers'
  require_relative './core_helpers'
  require_relative './fcart_helpers'
  require_relative './lhmc_helpers'

  FIXTUREDIR = 'spec/fixtures/files/xml'

  def base_cache_config
    {
      search_enabled: true,
      search_identifiers: false
    }
  end

  # returns RecordMapper hash read in from JSON file
  # path = String. Path to JSON file
  # turns strings into symbols that removed when writing to JSON
  # we can't just use the json symbolize_names option because @docstructure keys must
  #   remain strings
  def get_json_record_mapper(path)
    JSON.parse(File.read(path))
  end

  def get_record_mapper_object(path, cache = nil)
    CS::Mapper::RecordMapper.new(mapper: File.read(path), termcache: cache)
  end

  def get_datahash(path:)
    JSON.parse(File.read(path))
  end

  # The way CollectionSpace uses different URIs for the same namespace prefix in the same
  #  document is irregular and makes it impossible to query a document via xpath if
  #  the namespaces are defined. For testing, remove them...
  def remove_namespaces(doc)
    doc = doc.clone
    doc.remove_namespaces!
    doc.xpath('/*/*').each{ |n| n.name = n.name.sub('ns2:', '') }
    doc
  end

  def remove_blank_structured_dates(doc)
    doc.traverse do |node|
      # CSpace saves empty structured date fields with only a scalarValuesComputed value of false
      # we don't want to compare against these empty nodes
      node.remove if node.name['Date'] && node.text == 'false'
    end
    doc
  end

  def get_xml_fixture(filename, remove_blanks = true)
    doc = remove_namespaces(Nokogiri::XML(File.read("#{FIXTUREDIR}/#{filename}")){ |c| c.noblanks })
    doc = remove_blank_structured_dates(doc)

    # fields to omit from testing across the board
    rejectfields = %w[computedCurrentLocation].sort
    doc.traverse do |node|
      # Drop empty nodes
      if remove_blanks
        node.remove unless node.text.match?(/\S/m)
      end
      # Drop sections of the document we don't write with the mapper
      node.remove if node.name == 'collectionspace_core' || node.name == 'account_permission'
      # Drop fields created by CS application
      node.remove if rejectfields.bsearch{ |f| f == node.name }
    end
    doc
  end

  def get_xpaths(doc)
    xpaths = []
    doc.traverse{ |node| xpaths << node.path }
    xpaths.sort!
  end

  # removes paths for nodes in hierarchy that do not have their own values
  def field_value_xpaths(xpaths)
    xpaths.reject{ |path| xpaths.after(path).start_with?(path) }
  end

  # returns array of just the most specific xpaths from cleaned fixture XML for testing
  # removes fields not included in the RecordMapper mappings (which may be set in the XML due to weird
  #  default stuff in the application/services layer, but don't need to be in mapped XML)
  # testdoc should be the result of calling get_xml_fixture
  def test_xpaths(testdoc, mappings)
    xpaths = list_xpaths(testdoc)
    mapper_defined_paths(xpaths, mappings)
  end

  def mapper_defined_paths(xpaths, mappings)
    mappaths = mappings.map{ |mapping| "/document/#{mapping.fullpath}/#{mapping.fieldname}" }

    xpaths.select do |path|
      path = remove_xpath_occurrence_indicators(path)
      mappaths.any?{ |e| path.start_with?(e) }
    end
  end

  def remove_xpath_occurrence_indicators(path)
    path.match(/^(.*)\//)[1].gsub(/\[\d+\]/, '')
  end

  def list_xpaths(doc)
    xpaths = get_xpaths(doc)
    xpaths = field_value_xpaths(xpaths)
    xpaths
  end

  def standardize_value(string)
    if string.start_with?('urn:cspace')
      val = string.sub(/(item:name\([a-zA-Z]+)\d+(\)')/, '\1\2')
    else
      val = string
    end
    val
  end

  def populate(cache, terms)
    terms.each do |term|
      cache.put(*term)
    end
    cache
  end

end

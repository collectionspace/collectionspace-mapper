# frozen_string_literal: true

require "memo_wise"

module Helpers
  prepend MemoWise
  extend self

  require_relative "csids"
  require_relative "refnames"
  require_relative "anthro_helpers"
  require_relative "bonsai_helpers"
  require_relative "botgarden_helpers"
  require_relative "core_helpers"
  require_relative "fcart_helpers"
  require_relative "lhmc_helpers"

  FIXTUREDIR = "spec/support/xml"

  def base_cache_config
    {}
  end

  # returns RecordMapper hash read in from JSON file
  # path = String. Path to JSON file
  # turns strings into symbols that removed when writing to JSON
  # we can't just use the json symbolize_names option because @docstructure keys
  #   must remain strings
  def get_json_record_mapper(name)
    path = "spec/support/mappers/#{name}.json"
    JSON.parse(File.read(path))
  end

  # @todo remove after refactoring config
  def setup(profile: "core", mapper: nil)
    CollectionSpace::Mapper.config.client = send("#{profile}_client".to_sym)
    CollectionSpace::Mapper.config.termcache = send("#{profile}_cache".to_sym)
    CollectionSpace::Mapper.config.csidcache = send(
      "#{profile}_csid_cache".to_sym
    )
    if mapper
      setup_recordmapper(mapper)
    end
  end

  def setup_handler(mapper:, profile: "core", config: {})
    client = send("#{profile}_client".to_sym)
    termcache = send("#{profile}_cache".to_sym)
    csidcache = send("#{profile}_csid_cache".to_sym)
    mapper = get_json_record_mapper(mapper)
    CollectionSpace::Mapper::DataHandler.new(
      record_mapper: mapper,
      client: client,
      cache: termcache,
      csid_cache: csidcache,
      config: config
    )
  end

  # @todo remove after refactoring config
  def setup_recordmapper(mapper)
    CollectionSpace::Mapper.config.recordmapper =
      CollectionSpace::Mapper::RecordMapper.new(
        mapper: get_json_record_mapper(mapper)
      )
  end

  def get_record_mapper_object(path, cache = nil)
    CollectionSpace::Mapper::RecordMapper.new(mapper: File.read(path))
  end

  def get_datahash(path:)
    JSON.parse(File.read(path))
  end

  # The way CollectionSpace uses different URIs for the same namespace prefix in
  #   the same document is irregular and makes it impossible to query a document
  #   via xpath if the namespaces are defined. For testing, remove them...
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
        File.read("#{FIXTUREDIR}/#{filename}")
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

  # returns array of just the most specific xpaths from cleaned fixture XML for
  #   testing removes fields not included in the RecordMapper mappings (which
  #   may be set in the XML due to weird default stuff in the
  #   application/services layer, but don't need to be in mapped XML)
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

  def populate(cache, terms)
    terms.each do |term|
      cache.put(*term)
    end
    cache
  end
end

require 'collectionspace/mapper/version'
require 'collectionspace/client'
require 'collectionspace/refcache'

require 'benchmark'
require 'json'
require 'logger'
require 'pp'

require 'facets/array/before'
require 'facets/kernel/blank'
require 'nokogiri'
require 'xxhash'
require 'ruby-prof'

module CollectionSpace
  module Mapper
    ::Mapper = CollectionSpace::Mapper

    LOGGER = Logger.new(STDERR)
    DEFAULT_CONFIG = { delimiter: ';', subgroup_delimiter: '^^',
                      response_mode: 'normal' }

    require 'collectionspace/mapper/data_handler'
    require 'collectionspace/mapper/data_mapper'
    require 'collectionspace/mapper/data_prepper'
    require 'collectionspace/mapper/data_quality_checker'
    require 'collectionspace/mapper/data_splitter'
    require 'collectionspace/mapper/data_validator'
    require 'collectionspace/mapper/response'
    require 'collectionspace/mapper/value_transformer'

    require 'collectionspace/mapper/tools/authorities'
    require 'collectionspace/mapper/tools/config'
    require 'collectionspace/mapper/tools/dates'
    require 'collectionspace/mapper/tools/identifiers'
    require 'collectionspace/mapper/tools/record_mapper'
    require 'collectionspace/mapper/tools/vocabularies'
  end    
end

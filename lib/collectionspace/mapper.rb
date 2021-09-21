require 'collectionspace/mapper/version'
require 'collectionspace/client'
require 'collectionspace/refcache'

require 'benchmark'
require 'json'
require 'logger'
require 'pp'

require 'emendate'
require 'facets/array/before'
require 'facets/kernel/blank'
require 'nokogiri'
require 'xxhash'

module CollectionSpace
  ::CS = CollectionSpace
  module Mapper
    extend self
    LOGGER = Logger.new(STDERR)

    THE_BOMB = "\u{1F4A3}"
    
    Dir[File.dirname(__FILE__) + 'mapper/tools/*.rb'].sort.each do |file|
      require "collectionspace/mapper/tools/#{File.basename(file, File.extname(file))}"
    end
    Dir[File.dirname(__FILE__) + '/mapper/identifiers/*.rb'].sort.each do |file|
      require "collectionspace/mapper/identifiers/#{File.basename(file, File.extname(file))}"
    end
    Dir[File.dirname(__FILE__) + '/mapper/*.rb'].sort.each do |file|
      require "collectionspace/mapper/#{File.basename(file, File.extname(file))}"
    end

    module Errors
        class UnprocessableDataError < StandardError
          UnprocessableDataError = CollectionSpace::Mapper::Errors::UnprocessableDataError
        attr_reader :input
        def initialize(message, input)
          super(message)
          @input = input
        end
      end
    end

    def setup_data(data, config = Mapper::Config.new)
      if data.is_a?(Hash)
        response = Response.new(data)
      elsif data.is_a?(CollectionSpace::Mapper::Response)
        response = data
      else
        raise Errors::UnprocessableDataError.new("Cannot process a #{data.class}. Need a Hash or Mapper::Response", data)
      end

      response.merged_data.empty? ? merge_default_values(response, config) : response
    end

    def merge_default_values(data, batchconfig)
      defaults = batchconfig.default_values
      return data unless defaults
      
      mdata = data.orig_data.clone
      defaults.each do |f, val|
        if batchconfig.force_defaults
          mdata[f] = val
        else
          dataval = data.orig_data.fetch(f, nil)
          mdata[f] = val if dataval.nil? || dataval.empty?
        end
      end
      data.merged_data = mdata.compact.transform_keys(&:downcase)
      data
    end
    
    def term_key(term)
      "#{term[:refname].type}-#{term[:refname].subtype}-#{term[:refname].display_name}"
    end

  end    
end

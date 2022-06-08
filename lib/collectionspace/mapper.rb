# frozen_string_literal: true

require 'collectionspace/mapper/version'
require 'collectionspace/client'
require 'collectionspace/refcache'

require 'active_support'
require 'active_support/core_ext/object/blank'

require 'benchmark'
require 'json'
require 'logger'
require 'pp'

require 'nokogiri'
require 'xxhash'
require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.inflector.inflect(
  "version"   => "VERSION"
)
loader.push_dir("#{__dir__}/mapper", namespace: CollectionSpace::Mapper)
loader.setup
loader.eager_load

module CollectionSpace
  module Mapper
    LOGGER = Logger.new(STDERR)

    THE_BOMB = "\u{1F4A3}"

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

    module_function
    
    def setup_data(data, config = Mapper::Config.new)
      if data.is_a?(Hash)
        response = Response.new(data)
      elsif data.is_a?(CollectionSpace::Mapper::Response)
        response = data
      else
        raise Errors::UnprocessableDataError.new("Cannot process a #{data.class}. Need a Hash or Mapper::Response",
                                                 data)
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
  end
end

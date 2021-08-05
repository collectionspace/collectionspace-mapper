# frozen_string_literal: true

# This is here to use to run code profiling with https://ruby-prof.github.io/
# It should only be run manually for development purposes
require 'ruby-prof'
require 'bundler/setup'
require 'collectionspace/mapper'
require_relative './helpers'

Helpers.populate_anthro(Helpers.anthro_cache)

def mapping_workflow
  config = {
    delimiter: ';',
    subgroup_delimiter: '^^'
  }

  rm_anthro_co = Helpers.get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_collectionobject.json')
  handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: rm_anthro_co, cache: Helpers.anthro_cache, client: Helpers.anthro_client, config: config)

  datahash = Helpers.get_datahash(path: 'spec/fixtures/files/datahashes/anthro/collectionobject2.json')

  v_result = handler.validate(datahash)

  if v_result.valid?
    result = handler.process(datahash)
  end
  result
end

mapping_workflow

# RubyProf.start
# mapping_workflow
# result = RubyProf.stop
# printer = RubyProf::MultiPrinter.new(result)
# printer.print(path: './tmp', profile: 'workflow')

# frozen_string_literal: true

require "spec_helper"

# Used to test that expected XML is generated for a single data hash in a
#  file.
RSpec.shared_context "data_mapper" do
  subject(:mapped){ handler.process(response) }

  let(:handler) do
    setup_handler(
      profile: profile,
      mapper: mapper,
      config: config
    )
  end
  let(:baseconfig){ {delimiter: ";"} }
  let(:customcfg){ {} }
  let(:config){ baseconfig.merge(customcfg) }

  let(:datahash) { get_datahash(path: datahash_path) }
  let(:response) { CollectionSpace::Mapper::Response.new(datahash, handler) }
  let(:mapped_doc) { remove_namespaces(mapped.doc) }
end

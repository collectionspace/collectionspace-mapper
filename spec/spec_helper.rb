# frozen_string_literal: true

require "bundler/setup"

require "simplecov"
SimpleCov.start do
  enable_coverage :branch
end

require "collectionspace/mapper"
require_relative "./helpers"
require "pry"
require "vcr"
require "webmock/rspec"

RSpec.configure do |config|
  config.include Helpers

  # random but deterministic test order
  config.order = :random
  Kernel.srand config.seed

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.max_formatted_output_length = nil
  end

  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end
end

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = false
  c.cassette_library_dir = "spec/fixtures/cassettes"
  c.hook_into :webmock
  c.default_cassette_options = {record: :new_episodes}
  c.preserve_exact_body_bytes do |http_message|
    http_message.body.encoding.name == "ASCII-8BIT" ||
      !http_message.body.valid_encoding?
  end
  c.configure_rspec_metadata!
#  c.debug_logger = $stderr
end

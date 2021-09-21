# frozen_string_literal: true

# standard library
require 'optparse'
require 'csv'
require 'json'
require 'pp'

# other dependencies
require 'bundler/inline'
require 'pry'

gemfile do
  source 'https://rubygems.org'
  gem 'pry'
end

options = {}
OptionParser.new{ |opts|
  opts.banner = 'Usage: ruby datahash-to-csv.rb -i PATH_TO_JSON'

  opts.on('-i', '--input PATH_TO_JSON', 'Path to JSON datahash file.'){ |i|
    options[:input] = i
    unless File.file?(i)
      puts "File #{i} does not exist"
      exit
    end
    unless i.match?(/\.json/)
      puts "File #{i} does not have '.json' suffix"
      exit
    end
  }
  opts.on('-h', '--help', 'Prints this help'){
    puts opts
    exit
  }
}.parse!

dir = options[:input]['/'] ? options[:input].sub(/\/[^\/]+$/, '/') : ''
filename_stub = options[:input].sub(/^.*\//, '').sub('.json', '')
csv_file = "#{dir}#{filename_stub}.csv"

data = JSON.parse(File.read(options[:input]))

CSV.open(csv_file, 'wb') do |csv|
  csv << data.keys
  csv << data.values
end

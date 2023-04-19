# frozen_string_literal: true

# standard library
require "optparse"
require "csv"
require "json"

# other dependencies
require "bundler/inline"
require "pry"

gemfile do
  source "https://rubygems.org"
  gem "pry"
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby csv-to-datahashes.rb -i PATH_TO_CSV"

  opts.on("-i", "--input PATH_TO_CSV",
    "Path to CSV file. One JSON file will be created per row in the "\
      "same directory.") do |i|
    options[:input] = i
    unless File.file?(i)
      puts "File #{i} does not exist"
      exit
    end
    unless i.match?(/\.csv/)
      puts "File #{i} does not have '.csv' suffix"
      exit
    end
  end
  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

datahashes = []

filename_stub = options[:input].sub(%r{^.*/}, "").sub(".csv", "")
dir = options[:input]["/"] ? options[:input].sub(%r{/[^/]+$}, "/") : ""

CSV.foreach(options[:input], headers: true) do |row|
  datahashes << row.to_h
end

puts "#{datahashes.size} datahashes"

datahashes.map!{ |dh| dh.compact }
datahashes.map!{ |dh| JSON.pretty_generate(dh) }

datahashes.each_with_index do |dh, i|
  rownum = i + 2
  outputpath = "#{dir}#{filename_stub}_#{rownum}.json"
  File.write(outputpath, dh)
  puts "Wrote #{outputpath}"
end

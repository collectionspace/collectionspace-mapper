# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github){ |repo_name| "https://github.com/#{repo_name}" }

ruby '2.7.4'

# This is the version used by collectionspace-csv-importer
gem "activesupport", "= 6.0.4.7"
gem 'chronic'
gem 'collectionspace-client', tag: 'v0.14.1', git: 'https://github.com/collectionspace/collectionspace-client.git'
gem 'collectionspace-refcache', tag: 'v1.0.0', git: 'https://github.com/collectionspace/collectionspace-refcache.git'
gem 'dry-configurable', '~>0.14'
gem 'memo_wise', '~> 1.1.0'
gem 'nokogiri', '~> 1.13.3'
gem 'xxhash', '>= 0.4.0'
gem 'zeitwerk', '~> 2.5'

group :development do
  gem 'bundler', '>= 2.1.2'
  gem 'byebug'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rake', '>= 13.0.1'
  gem 'rubocop', '~> 1.18.3'
end

group :development, :test do
  gem 'rspec', '~> 3.0'
end

group :development, :benchmark do
  gem 'ruby-prof', '~> 1.4.3'
  gem 'time_up', '~> 0.0.7'
end





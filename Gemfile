# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github){ |repo_name| "https://github.com/#{repo_name}" }

ruby '2.7.4'

gem 'collectionspace-client', tag: 'v0.14.1', git: 'https://github.com/collectionspace/collectionspace-client.git'
gem 'collectionspace-refcache', tag: 'v1.0.0', git: 'https://github.com/collectionspace/collectionspace-refcache.git'

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

gemspec


lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'collectionspace/mapper/version'

Gem::Specification.new do |spec|
  spec.name          = 'collectionspace-mapper'
  spec.version       = CollectionSpace::Mapper::VERSION
  spec.authors       = ['Kristina Spurgin']
  spec.email         = ['kristina.spurgin@lyrasis.org']

  spec.summary       = %q{Generic mapper turns hash of data into CollectionSpace XML}
  spec.homepage      = 'https://github.com/lyrasis/collectionspace-mapper'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.7.2'
  
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'TODO: Set to "http://mygemserver.com"'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/lyrasis/collectionspace-mapper'
    spec.metadata['changelog_uri'] = 'https://github.com/lyrasis/collectionspace-mapper'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'chronic'
  spec.add_dependency 'facets'
  spec.add_dependency 'nokogiri', '>= 1.10.9'
  spec.add_dependency 'xxhash', '>= 0.4.0'

  spec.add_development_dependency 'bundler', '>= 2.1.2'
  spec.add_development_dependency "pry", ">= 0.13.0"
  spec.add_development_dependency 'rake', '>= 13.0.1'
  spec.add_development_dependency 'rspec', '~> 3.0'
end

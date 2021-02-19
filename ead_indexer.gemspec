$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ead_indexer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ead_indexer"
  s.version     = EadIndexer::VERSION
  s.authors     = ["Eric Griffis"]
  s.email       = ["eric.griffis@nyu.edu"]
  s.homepage    = "https://github.com/NYULibraries/ead_indexer"
  s.summary     = "Generic EAD indexing"
  s.description = "Generic EAD indexing"
  s.license     = "MIT"

  s.files = Dir["{app,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/**/**/**/*"]

  s.add_dependency "rails", ">= 4.2.7.1", "< 6"
  s.add_dependency 'solr_ead', '~> 0.7.5'
  s.add_dependency 'rsolr', '~> 1.0'
  s.add_dependency 'iso-639', '>= 0.2.5'
  s.add_dependency 'prometheus-client', '>= 2.1.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec-its', '~> 1.2.0'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'sqlite3'
end

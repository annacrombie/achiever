# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'achiever/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'achiever'
  spec.version     = Achiever::VERSION
  spec.authors     = ['Stone Tickle']
  spec.email       = ['lattis@mochiro.moe']
  spec.summary     = 'Simple gameification'
  spec.license     = 'MIT'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '~> 5.2.2'
  spec.add_dependency 'sass'
  spec.add_dependency 'kaicho'
  spec.add_dependency 'settei'

  spec.add_development_dependency 'rspec-rails', '~> 3.8'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3'
end

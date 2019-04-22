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

  spec.add_dependency 'bootstrap', '~> 4.3'
  spec.add_dependency 'jquery-rails'

  spec.add_dependency 'hash_validator', '~> 0.8'
  spec.add_dependency 'kaicho', '~> 0.3.1'
  spec.add_dependency 'rails', '~> 5.2'
  spec.add_dependency 'rails-observers'
  spec.add_dependency 'sass', '~> 3.7'
  spec.add_dependency 'hummus', '~> 0.3'
  spec.add_dependency 'chickpea', '~> 0.2.1'

  spec.add_development_dependency 'rspec-rails', '~> 3.8'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
  spec.add_development_dependency 'timecop', '~>0.9'
end

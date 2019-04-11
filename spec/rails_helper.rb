require 'timecop'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/config/'

  add_group 'controllers', 'app/controllers'
  add_group 'helpers', 'app/helpers'
  add_group 'lib', 'lib/'
  add_group 'models', 'app/models'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../dummy/config/environment', __FILE__)
require 'rails-observers'
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'achiever'
require_relative 'support/helpers'
require 'spec_helper'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

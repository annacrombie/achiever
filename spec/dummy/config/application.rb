# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require 'rails-observers'
#require 'jquery-rails'
#require 'bootstrap'

require 'achiever'

module Dummy
  class Application < Rails::Application
    config.load_defaults 5.2

    config.active_record.observers = ['trackers/test_tracker']
  end
end

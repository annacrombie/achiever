# frozen_string_literal: true

require 'achiever/badge'
require 'achiever/config'
require 'achiever/engine'
require 'achiever/exceptions'
require 'achiever/helpers'
require 'achiever/validator'

module Achiever
  include Config

  class<<self
    def validate(achievement)
      unless achievements.key?(achievement)
        raise(InvalidAchievementName, achievement)
      end
    end

    def config_file
      file = File.open(Rails.root.join(config[:achievements_file]), 'r')

      if config[:mtime] < file.mtime
        @config[:mtime] = file.mtime

        data = YAML.safe_load(file.read)

        Validator.new(data).validate

        @config[:data] = data
      end

      file.close

      @config[:data]
    end

    def achievements
      config_file['achievements']
    end

    def achievement(name)
      validate(name)
      achievements[name]
    end

    def badges(name, have: 0)
      achievement(name)['badges'].map do |bdg|
        Badge.new(name, bdg['required'], have)
      end
    end

    def badge_attr(name, reqd)
      achievement(name)['badges'].detect { |e| e['required'] == reqd }
    end

    def badge(name, reqd)
      bdg = badge_attr(name, reqd)
      Badge.new(name, bdg['required'], 0)
    end
  end
end

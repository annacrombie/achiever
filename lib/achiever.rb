# frozen_string_literal: true

require 'hash_validator'
require 'kaicho'
require 'settei'

require 'achiever/types'

require 'achiever/badge'
require 'achiever/config'
require 'achiever/config_validator'
require 'achiever/engine'
require 'achiever/exceptions'
require 'achiever/logic'
require 'achiever/subject'
require 'achiever/util'

# Achiever, add achievements to your app
module Achiever
  include Settei.cfg(
    file: 'config/achievements.yml',
    defaults: {
      badge: { img: '' },
      achievement: {
        type: 'cumulative',
        visibility: 'visible'
      }
    },
    icon_cfg: {
      source: 'badges',
      output: {
        width: 70,
        css: 'app/assets/stylesheets/badges.css.erb',
        image: 'badges.png',
        dir: 'app/assets/images'
      }
    },
    use_aws_in_production: false
  )

  class<<self
    def check_name(achievement)
      unless achievements.key?(achievement)
        raise(Exceptions::InvalidAchievementName, achievement)
      end
    end

    def achievements
      disk_config.achievements
    end

    # get the processed configuration for an achievement
    def achievement(name)
      name = name.to_sym
      check_name(name)
      achievements[name]
    end

    private

    # Lazy-loads the configuration from the disk (config/achievements.yml) by
    # default
    def disk_config
      @disk_config ||= Config.new(file)
    end
  end
end

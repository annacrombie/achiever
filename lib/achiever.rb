# frozen_string_literal: true

require 'hash_validator'
require 'kaicho'
require 'settei'

require 'achiever/badge'
require 'achiever/config'
require 'achiever/config_validator'
require 'achiever/engine'
require 'achiever/exceptions'
require 'achiever/logic'
require 'achiever/subject'
require 'achiever/util'

module Achiever
  include Settei.cfg(
    file: 'config/achievements.yml',
    defaults: {
      badge: { img: '' },
      achievement: {
        type: 'accumulation',
        visibility: 'visible'
      }
    },
    achievements_path: 'achievements',
    icon_cfg: {
      source: 'badges',
      output: {
        width: 70,
        css: 'app/assets/stylesheets/badges.css.erb',
        image: 'badges.png',
        dir: 'app/assets/images'
      },
    },
    use_aws_in_production: false
  )

  class<<self
    def check_name(achievement)
      unless achievements.key?(achievement)
        raise(Exceptions::InvalidAchievementName, achievement)
      end
    end

    def disk_config
      @disk_config ||= Config.new(file)
    end

    def achievements
      disk_config.achievements
    end

    def achievement(name)
      name = name.to_sym
      check_name(name)
      achievements[name]
    end

    def badges(name, have: 0)
      achievement(name)[:badges].map do |bdg|
        Badge.new(name, bdg[:required], have)
      end
    end

    def badge(name, reqd, have: 0)
      bdg = achievement(name)[:badges].detect { |e| e[:required] == reqd }
      Badge.new(name, bdg[:required], have)
    end
  end
end

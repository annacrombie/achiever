# frozen_string_literal: true

require 'hash_validator'
require 'kaicho'
require 'settei'

require 'achiever/achievements'
require 'achiever/badge'
require 'achiever/config_validator'
require 'achiever/engine'
require 'achiever/exceptions'
require 'achiever/helpers'
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
    })


  class<<self
    def check_name(achievement)
      unless achievements.key?(achievement)
        raise(Exceptions::InvalidAchievementName, achievement)
      end
    end

    def achievements
      @achievements ||= Achievements.new
      @achievements.achievements
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

    def badge_attr(name, reqd)
      achievement(name)[:badges].detect { |e| e[:required] == reqd }
    end

    def badge(name, reqd)
      bdg = badge_attr(name, reqd)
      Badge.new(name, bdg[:required], 0)
    end

    def attained?(name, reqd, have)
      cfg = achievement(name)
      case cfg[:type]
      when 'slotted'
        reqd & have == reqd
      when 'accumulation'
        have >= reqd
      end
    end
  end
end

# frozen_string_literal: true

require 'hash_validator'
require 'kaicho'
require 'hummus'

require 'achiever/types'

require 'achiever/badge'
require 'achiever/config'
require 'achiever/config_validator'
require 'achiever/engine'
require 'achiever/exceptions'
require 'achiever/logic'
require 'achiever/subject'
require 'achiever/tracker'
require 'achiever/translation_helper'
require 'achiever/util'

# Namespace for Achiever, a Rails engine to add achievements to your app
module Achiever

  # Set default config
  #
  # Config can be accessed by calling #config on Acheiver.
  # e.g., in order to access badge defaults
  #
  #     Achiever.config.defaults.badge #=> { img: '' }
  #
  # Config keys:
  #
  # - +file+ - path to yml that describes achievements
  # - +defaults+ - default parameters for badges and achievements
  #   - +badge+ - merged with each badge
  #   - +achievement+ - merged with each achievement
  # - +icon_cfg+ - configuration used by the achiever:badges rake task
  #   - +source+ - the source folder for badge images
  #   - +output+ - configuration for badge image processing
  #     - +width+ - the final width of each badge
  #     - +css+ - where to put generated css for sprites
  #     - +image+ - the name of the final image generated (also the key if
  #       uploading to aws)
  #     - +dir+ - where to put the generated image
  # - +use_aws_in_production+ - wether or not badge images should be loaded from
  #   an aws bucket in production
  # - +unachieved_badge_image+ - image to be used instead of badge when badge
  #   is unachieved
  include Hummus.setup(
    file: 'config/achievements.yml',
    subject: :current_user,
    defaults: {
      badge: { img: '' },
      achievement: {
        type: 'cumulative',
        visibility: 'visible'
      }
    },
    icons: {
      source: 'badges',
      output: {
        width: 70,
        css: 'app/assets/stylesheets/badges.css.erb',
        image: 'badges.png',
        dir: 'app/assets/images',
        aws_bucket: ''
      }
    },
    use_aws_in_production: false,
    unachieved_badge_image: 'badge_mystery'
  )

  class<<self
    # Checks if an achievement is valid, otherwise raises an exception
    #
    # @param [Symbol] achievement the achievement to check
    # @raise Exception::InvalidAchievementName
    def check_name(achievement)
      unless achievements.key?(achievement)
        raise(Exceptions::InvalidAchievementName, achievement)
      end
    end

    # Get the processed hash of achievements
    def achievements
      disk_config.achievements
    end

    # get the processed configuration for an achievement
    #
    # @param [Symbol] name the name of the acehievement
    def achievement(name)
      name = name.to_sym
      check_name(name)
      achievements[name]
    end

    # @see TranslationHelper#badge
    def tl_badge(ach, id, field, **opts)
      TranslationHelper.badge(ach, id, field, **opts)
    end

    # @see TranslationHelper#achievement
    def tl_achievement(name, field, **opts)
      TranslationHelper.achievement(name, field, **opts)
    end

    private

    # Lazy-loads the configuration from the disk
    def disk_config
      @disk_config ||= Config.new(config.file)
    end
  end
end

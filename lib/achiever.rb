require "achiever/badge"
require "achiever/config"
require "achiever/engine"
require "achiever/exceptions"
require "achiever/helpers"

module Achiever
  include Config
  class<<self
    def validate(achievement)
      unless achievements.key?(achievement)
        raise(InvalidAchievementName, achievement)
      end
    end

    def achievements
      file = File.open(Rails.root.join(config[:achievements_file]), 'r')

      if config[:mtime] < file.mtime
        @config.merge!(
          mtime: file.mtime,
          achievements: YAML.load(file.read)
        )
      end

      file.close

      @config[:achievements]
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

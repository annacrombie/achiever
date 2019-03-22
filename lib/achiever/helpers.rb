# frozen_string_literal: true

module Achiever
  module Helpers
    def has_achievement?(name)
      achievements.exists?(name: name)
    end

    def achievement(name)
      achievements.find_by(name: name)
    end

    def badges
      achievements.reduce({}) do |badges, achievement|
        badges[achievement.name] = achievement.badges
      end
    end

    def visible_badges
      Achiever.achievements.map do |name, props|
        [
          name,
          if has_achievement?(name)
            achievement(name).visible_badges
          elsif props['visibility'] == 'visible'
            Achiever.badges(name)
          end
        ]
      end.reject { |_n, b| b.nil? }.to_h
    end

    def badge_count
      achievements.reduce(0) do |c, achievement|
        c + achievement.badges_count
      end
    end

    def has_new_badges?
      achievements.any? { |ach| !ach.new_badges.empty? }
    end

    def new_badges
      achievements.map(&:new_badges).flatten
    end

    def clear_new_badges
      achievements.each(&:clear_new_badges)
    end

    attr_accessor :recent_achievements

    def achieve(name, progress: 1)
      if has_achievement?(name)
        achievement(name)
      else
        Achievement.new(name: name, user_id: id)
      end.achieve(progress)
    end
  end
end

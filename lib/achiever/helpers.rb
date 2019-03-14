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
      end.reject { |n, b| b.nil? }.to_h
    end

    def badge_count
      achievements.reduce(0) do |c, achievement|
        c + achievement.badges_count
      end
    end

    attr_accessor :recent_achievements

    def achieve(name, progress: 1)
      Achiever.validate(name)

      new_badges =
        unless has_achievement?(name)
          Achievement.new(name: name, user_id: id)
        else
          achievement(name)
        end.achieve(progress)

      unless new_badges.empty?
        @recent_achievements =
          (@recent_achievements || []) + new_badges.map(&:attr)
      end
    end
  end
end

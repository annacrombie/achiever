# frozen_string_literal: true

module Achiever
  module Helpers
    def achievements
      Achiever::Achievement.where(user_id: id)
    end

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
          elsif props[:visibility] == 'visible'
            Achiever.badges(name)
          end
        ]
      end.reject { |_n, b| b.nil? }.to_h
    end

    def has_new_badges?
      achievements.any? { |ach| ! ach.new_badges.empty? }
    end

    def new_badges
      achievements.map(&:new_badges).flatten
    end

    def clear_new_badges
      achievements.each(&:clear_new_badges)
    end

    def achieve(name, progress = nil)
      ach =
        if has_achievement?(name)
          achievement(name)
        else
          Achievement.new(name: name, user_id: id)
        end

      case ach.cfg[:type]
      when 'slotted'
        Achiever::Util.check_type(progress, Symbol)
        Achiever::Util.check_slot(progress, ach.cfg[:slots])

        ach.update(
          progress: Achiever::Logic.slotted_progress(
            ach.progress, ach.cfg[:slots], progress))
      when 'accumulation'
        progress = progress.nil? ? 1 : progress
        Achiever::Util.check_type(progress, Integer)

        ach.update(
          progress: Achiever::Logic.cumulative_progress(
            ach.progress, progress))
      end
    end
  end
end

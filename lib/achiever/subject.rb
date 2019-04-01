# frozen_string_literal: true

module Achiever
  module Subject
    def achievements
      Achievement.where(user_id: id)
    end

    def has_achievement?(name)
      achievements.exists?(name: name)
    end

    def achievement(name)
      achievements.find_by(name: name)
    end

    def badges
      achievements.reduce({}) do |badges, achievement|
        badges.merge(achievement.name => achievement.badges)
      end
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

    def achievement!(name)
      Achievement.find_or_create_by(name: name, user_id: id)
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def schedule_achievement(name, progress, on)
      achievement!(name).schedule(progress, on)
    end

    def achieve(name, progress = nil, on: nil)
      return schedule_achievement(name, progress, on) unless on.nil?

      achievement!(name).achieve(progress)
    end
  end
end

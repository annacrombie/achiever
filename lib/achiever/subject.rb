# frozen_string_literal: true

module Achiever
  module Subject
    class<<self
      def validate_subject(obj)
        unless obj.ancestors.include?(ApplicationRecord) &&
            obj.attribute_types[obj.primary_key].type == :integer
          raise(Exceptions::InvalidSubject)
        end
      rescue ActiveRecord::StatementInvalid
      end

      def append_features(rcvr, validate: true)
        validate_subject(rcvr) if validate

        super(rcvr)
      end
    end

    def achievements
      Achievement.where(subject_id: primary_key_value)
    end

    def scheduled_achievements(name = nil)
      ScheduledAchievement
        .joins(:achievement)
        .where(achiever_achievements: { subject_id: primary_key_value })
        .yield_self { |r| name.nil? ? r : r.where(achiever_achievements: { name: name }) }
    end

    def achievement(name)
      achievements.find_by(name: name)
    end

    def has_achievement?(name)
      achievements.exists?(name: name)
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
      Achievement.find_or_create_by(name: name, subject_id: primary_key_value)
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

    private

    def primary_key_value
      send(self.class.primary_key)
    end
  end
end

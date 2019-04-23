# frozen_string_literal: true

module Achiever
  module Subject
    class<<self
      # Makes sure that you include Subject into an ApplicationRecord with an
      # :integer typed primary key
      def validate_subject(obj)
        unless obj.ancestors.include?(ApplicationRecord) &&
            obj.attribute_types[obj.primary_key].type == :integer
          raise(Exceptions::InvalidSubject)
        end
      rescue ActiveRecord::StatementInvalid
      end

      def append_features(rcvr, validate: true)
        if validate
          raise(Exceptions::DuplicateSubject) unless Achiever.subject.nil?
          validate_subject(rcvr)
        end

        Achiever.subject = rcvr

        super(rcvr)
      end
    end

    # Get all a users achievements
    def achievements
      Achievement.where(subject_id: primary_key_value)
    end

    # Get all scheduled achievements for a user, if name is passed then only
    # find scheduled achievements belonging to that achievement
    def scheduled_achievements(name = nil)
      ScheduledAchievement
        .joins(:achievement)
        .where(achiever_achievements: { subject_id: primary_key_value })
        .yield_self { |r| name.nil? ? r : r.where(achiever_achievements: { name: name }) }
    end

    # Get an achievement by name
    def achievement(name)
      achievements.find_by(name: name)
    end

    # Wether or not this Subject has the named achievement
    def has_achievement?(name)
      achievements.exists?(name: name)
    end

    # Get a Hash of the users badges, organized by achievement name
    def badges
      achievements.reduce({}) do |badges, achievement|
        badges.merge(achievement.name => achievement.badges)
      end
    end

    # Checks if any achievement has new badges
    def has_new_badges?
      achievements.any? { |ach| ! ach.new_badges.empty? }
    end

    # A flat array of all the Subject's new badges
    def new_badges
      achievements.map(&:new_badges).flatten
    end

    # Clears all achievement's new badges
    def clear_new_badges
      achievements.each(&:clear_new_badges)
    end

    # Get an achievement by name, or create it if it doesn't exist
    def achievement!(name)
      Achievement.find_or_create_by(name: name, subject_id: primary_key_value)
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    # Schedule an achievement
    def schedule_achievement(name, progress, on)
      achievement!(name).schedule(progress, on)
    end

    # Achieve an achievement
    def achieve(name, progress = nil, on: nil)
      return schedule_achievement(name, progress, on) unless on.nil?

      achievement!(name).achieve(progress)
    end

    private

    # Get the value of this Subject's primary key
    def primary_key_value
      send(self.class.primary_key)
    end
  end
end

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
          if Achiever.subject.nil?
            Achiever.subject = rcvr
          elsif Achiever.subject != rcvr
            if Achiever.config.strict_subject?
              raise(Exceptions::DuplicateSubject)
            else
              warn("Re-including Achiever::Subject")
            end
          end

          validate_subject(rcvr)
        end

        super(rcvr)
      end
    end

    # Get all a users achievements
    def achievements
      Achievement.where(subject_id: primary_key_value)
    end

    # Get all scheduled achievements for a user, if name is passed then only
    # find scheduled achievements belonging to that achievement
    def scheduled_achievements
      ScheduledAchievement
        .joins(:achievement)
        .where(achiever_achievements: { subject_id: primary_key_value })
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
      achievements
        .joins(:scheduled_achievements)
        .tap { |as| as.each { |a| a.scheduled_achievements.where(due: Time.at(0)..Time.now).each(&:apply) } }
        .any? { |ach| ! ach.new_badges.empty? }
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

    # Get the value of this Subject's primary key
    def primary_key_value
      send(self.class.primary_key)
    end
  end
end

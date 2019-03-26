# frozen_string_literal: true

module Achiever
  module Helpers
    def has_achievement?(name)
      name = name.to_sym
      achievements.exists?(name: name)
    end

    def achievement(name)
      name name.to_sym
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

    def achieve(name, progress = nil, set: nil)
      name = name.to_sym
      if has_achievement?(name)
        achievement(name)
      else
        Achievement.new(name: name, user_id: id)
      end.yield_self do |ach|
        case ach.cfg[:type]
        when 'slotted'
          raise(
            TypeError,
            "The achievement #{name} requires a Symbol progress"
          ) unless progress.is_a?(Symbol)

          raise(
            Exceptions::InvalidSlot, "#{progress}"
          ) unless ach.cfg[:slots].include?(progress)

          ach.update(progress: ach.progress | (2 ** (ach.cfg[:slots].index(progress) + 1)))
        when 'accumulation'
          progress = progress.nil? ? 1 : progress

          raise(
            TypeError,
            "The achievement #{name} requires an Integer progress"
          ) unless progress.is_a?(Integer)

          ach.update(progress: ach.progress + progress)
        end
      end
    end
  end
end

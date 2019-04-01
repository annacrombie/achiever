module Achiever
  class ScheduledAchievement < ApplicationRecord
    belongs_to :achievement

    def apply
      achievement.update(progress: achievement.progress + payload)
      destroy
    end

    def tags
      @tags ||= self[:tags].split(',').map(&:to_sym)
    end

    def tag(t)
      tags << t.to_s
      self[:tags] = tags.join(',')
    end

    def tag!(t)
      tag(t)
      save
    end
  end
end

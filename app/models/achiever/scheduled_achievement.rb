module Achiever
  class ScheduledAchievement < ApplicationRecord
    belongs_to :achievement

    def apply
      achievement.achieve_raw(payload)
      destroy
    end

    def tags
      @tags ||= self[:tags].nil? ? [] : self[:tags].split(',').map(&:to_sym)
    end

    def tag(t)
      tags << t.to_s
      self[:tags] = tags.join(',')
      self
    end

    def tag!(t)
      tag(t)
      save
      self
    end
  end
end

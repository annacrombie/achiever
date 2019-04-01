module Achiever
  class ScheduledAchievement < ApplicationRecord
    belongs_to :achievement

    def apply
      achievement.update(progress: achievement.progress + payload)
      destroy
    end
  end
end

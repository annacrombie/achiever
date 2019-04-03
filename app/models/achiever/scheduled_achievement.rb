module Achiever
  class ScheduledAchievement < ApplicationRecord
    class<<self
      alias_method :cancel_all, :destroy_all
    end
    alias_method :cancel, :destroy

    belongs_to :achievement

    scope(:tagged, lambda do |*tags|
      where('tags LIKE ?', "%#{tags.map(&:to_sym).sort.uniq.join('%')}%")
    end)

    def apply
      achievement.achieve_raw(payload)
      destroy
    end

    def setup_tags
      @tags ||= self[:tags].nil? ? [] : self[:tags].split(',').map(&:to_sym)
    end

    def tag(*t)
      setup_tags
      @tags += t.map(&:to_sym)
      @tags.sort!.uniq!
      self[:tags] = @tags.join(',')
      self
    end

    def tag!(*t)
      tag(*t)
      save
      self
    end
  end
end

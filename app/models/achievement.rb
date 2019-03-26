# frozen_string_literal: true

class Achievement < ApplicationRecord
  validate :valid_achievement_name

  def valid_achievement_name
    unless Achiever.achievements.key?(name.to_sym)
      errors.add(:name, "no such achievement '#{name}'")
    end
  end

  def badges
    Achiever.badges(name, have: progress).select(&:achieved)
  end

  def remaining_badges
    Achiever.badges(name, have: progress).reject(&:achieved)
  end

  def all_badges
    badges + remaining_badges
  end

  def visible_badges
    cfg[:visibility] == 'visible' ? all_badges : badges
  end

  def new_badges
    cfg[:badges].map do |badge|
      if !Achiever.attained_badge?(name, badge[:required], progress) &&
          Achiever.attained_badge?(name, badge[:required], notified_progress)
        Achiever::Badge.new(name, badge[:required], progress)
      end
    end.compact
  end

  def clear_new_badges
    update(notified_progress: progress)
  end

  def cfg
    @cfg ||= Achiever.achievement(name)
  end
end

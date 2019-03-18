class Achievement < ApplicationRecord
  validate :valid_achievement_name
  def valid_achievement_name
    unless Achiever.achievements.key?(name)
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
    if Achiever.achievement(name)['visibility'] == 'visible'
      all_badges
    else
      badges
    end
  end

  def badges_count
    Achiever.achievement(name)['badges'].reduce(0) do |c, badge|
      progress >= badge['required'] ? c + 1 : c
    end
  end

  def new_badges
    Achiever.achievement(name)['badges'].map do |badge|
      if badge['required'] > notified_progress &&
          badge['required'] <= progress
        Achiever::Badge.new(name, badge['required'], progress)
      end
    end.compact
  end

  def clear_new_badges
    update(notified_progress: progress)
  end

  def achieve(new_progress)
    self[:progress] += new_progress
    save
  end
end

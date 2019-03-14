class AchievementsController < ApplicationController
  def index
    @achievements = current_user.visible_badges
  end
end

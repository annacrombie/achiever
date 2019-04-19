# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :randomize_achievements
  after_action :destroy_user

  def randomize_achievements
    Achiever.achievements.keys
            .each { |k| current_user.achievement!(k)
            .then { |a| a.update(progress: (a.overall_progress[1] * rand).round) }}
  end

  def destroy_user
    current_user.destroy
  end

  def current_user
    if User.first.nil?
      User.create
    else
      User.first
    end
  end
end

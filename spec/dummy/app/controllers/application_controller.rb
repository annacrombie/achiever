# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Achiever::AchieverHelper
  before_action :randomize_achievements, :set_achiever_subject
  after_action :destroy_user

  def set_achiever_subject
    self.achiever_subject = current_user
  end

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

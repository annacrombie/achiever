require_dependency 'achiever/application_controller'

module Achiever
  class AchievementsController < ApplicationController
    def index
      @achievements =
        Achiever.achievements.map do |name, _|
          ach = achiever_subject.achievement!(name)
          { name: name, prog: ach.overall_progress, badges: ach.visible_badges }
        end.reject { |a| a[:badges].empty? }

      render 'achiever/achievements'
    rescue ActionView::MissingTemplate
    end
  end
end

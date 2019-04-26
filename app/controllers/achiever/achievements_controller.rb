require_dependency 'achiever/application_controller'

module Achiever
  class AchievementsController < ApplicationController
    def index
      pkv = achiever_subject.primary_key_value
      have = {}
      achiever_subject.achievements.each do |ach|
        ach.subject = achiever_subject
        have[ach.name] = ach
      end

      @achievements =
        Achiever.achievements.map do |name, _|
          have[name].then do |db_ach|
            (db_ach || Achievement.new(name: name, subject_id: pkv)
            ).then do |ach|
              { name: name, prog: ach.overall_progress, badges: ach.visible_badges }
            end
          end
        end.reject { |a| a[:badges].empty? }

      render 'achiever/achievements'
    rescue ActionView::MissingTemplate
    end
  end
end

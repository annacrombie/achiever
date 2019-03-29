# frozen_string_literal: true

require_dependency 'achiever/application_controller'

module Achiever
  class AchievementsController < ApplicationController
    def index
      unless instance_variable_defined?(:@achiever_subject)
        raise(Achiever::Exceptions::UninitializedAchieverSubject)
      end

      @achievements = @achiever_subject.visible_badges
      @progress =
        @achievements.keys.map do |k|
          [k, Logic.overall_progress(k, @achievements[k].first.have)]
        end.to_h
    end
  end
end

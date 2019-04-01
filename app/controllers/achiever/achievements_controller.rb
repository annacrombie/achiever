# frozen_string_literal: true

require_dependency 'achiever/application_controller'

module Achiever
  class AchievementsController < ApplicationController
    def index
      unless instance_variable_defined?(:@achiever_subject)
        raise(Achiever::Exceptions::UninitializedAchieverSubject)
      end

      @achievements =
        Achiever.achievements.map do |name, _|
          ach = @achiever_subject.achievement!(name)
          { name: name, prog: ach.overall_progress, badges: ach.visible_badges }
        end.reject { |a| a[:badges].empty? }
    end
  end
end

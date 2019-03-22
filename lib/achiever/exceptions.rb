# frozen_string_literal: true

module Achiever
  class InvalidAchievementName < StandardError
    def initialize(name)
      super("Invalid achievement name: '#{name}'")
    end
  end
end

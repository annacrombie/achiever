# frozen_string_literal: true
module Achiever
  class Achievement < ApplicationRecord
    include Types::Base

    has_many :scheduled_achievements
    after_initialize :inherit_type
    validates :name, uniqueness: { scope: :subject_id }
    attr_writer :subject

    def inherit_type
      Achiever::Util.instance_include(self, Achiever::Types.mod(cfg[:type]))
    end

    def subject
      @subject ||= Achiever.subject.find(subject_id)
    end

    def name
      @name ||= self[:name].to_sym
    end

    def achieved_badges
      badges.select(&:achieved?)
    end

    def badges
      cfg[:badges].map do |bdg|
        Badge.new(name, bdg[:required], achieved?(bdg[:required]))
      end
    end

    def visible?
      @visible ||= Achiever.visibilities.check(cfg[:visibility], self)
    end

    def visible_badges
      visible? ? badges : achieved_badges
    end

    def new_badges
      cfg[:badges].map do |bdg|
        if achieved?(bdg[:required]) &&
            !achieved?(bdg[:required], notified_progress)
          Badge.new(name, bdg[:required], true)
        end
      end.compact
    end

    def clear_new_badges
      update(notified_progress: progress)
    end

    def cfg
      @cfg ||= Achiever.achievement(name)
    end

    def check_scheduled_achievements
      scheduled_achievements.where(due: Time.at(0)..Time.now).each(&:apply)
    end
  end
end

# frozen_string_literal: true

module Achiever
  # This class allows easy access
  class Badge
    attr_reader :achievement, :required

    def initialize(achievement, required, achieved)
      @achievement = achievement
      @required = required
      @achieved = achieved

      validate_required
    end

    def validate_required
      if badge_id.nil?
        raise(
          Achiever::Exceptions::NoSuchBadge,
          "achievement: #{achievement}, required: #{required}"
        )
      end
    end

    def badge_id
      @badge_id ||= cfg[:badges].index { |b| b[:required] == required }
    end

    def cfg
      @cfg ||= Achiever.achievement(achievement)
    end

    def name
      @name ||= Achiever.tl_badge(achievement, badge_id, :name)
    end

    def desc
      @desc ||=
        Achiever.tl_badge(achievement, badge_id, :desc, count: required)
    end

    def msg
      @msg ||=
        Achiever.tl_badge(achievement, badge_id, :msg, count: required)
    end

    def img
      @img ||= cfg[:badges][badge_id][:img]
    end

    def visibility
      @visibility ||= cfg[:visibility]
    end

    def achieved?
      @achieved
    end

    def attr
      @attr ||= {
        name: name,
        desc: desc,
        img: img,
        visibility: visibility,
        required: required,
        achievement: achievement,
        achieved: achieved?
      }
    end
  end
end

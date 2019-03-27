# frozen_string_literal: true

module Achiever
  class Badge
    def initialize(achievement, required, have)
      @ach = achievement
      @rqd = required
      @hve = have
    end

    def badge_id
      @badge_id ||= cfg[:badges].index { |b| b[:required] == @rqd }
    end

    def cfg
      @cfg ||= Achiever.achievement(@ach)
    end

    def name
      @name ||= I18n.t("achiever.achievements.#{@ach}.badges")[badge_id][:name]
    end

    def desc
      @desc ||= I18n.t("achiever.achievements.#{@ach}.desc", count: @rqd)
    end

    def img
      @img ||= cfg[:badges][badge_id][:img]
    end

    def visibilty
      @visibility ||= cfg['visibility']
    end

    def achieved?
      @achieved ||= Achiever.attained?(@ach, @rqd, @hve)
    end

    def attr
      @attr ||= {
        name: name,
        desc: desc,
        img: img,
        visibility: visibility,
        required: @rqd,
        have: @hve,
        achievement: @ach,
        achieved: achieved?
      }
    end

    def icon
      <<~BADGE
        <div class="badge_icon">
          <span
            class="#{achieved? ? 'achieved' : 'unachieved'} #{img}"
            title="#{desc}"
            data-toggle="tooltip"
            data-placement="top" >
          </span>
        </div>
      BADGE
        .html_safe
    end
  end
end

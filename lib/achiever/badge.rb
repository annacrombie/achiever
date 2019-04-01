# frozen_string_literal: true

module Achiever
  # This class allows easy access
  class Badge
    attr_reader :achievement, :required

    def initialize(achievement, required, achieved)
      @achievement = achievement
      @required = required
      @achieved = achieved
    end

    def badge_id
      @badge_id ||= cfg[:badges].index { |b| b[:required] == required }
    end

    def cfg
      @cfg ||= Achiever.achievement(achievement)
    end

    def tl
      @tl ||=
        catch(:exception) do
          I18n.t("achiever.achievements.#{achievement}.badges", throw: true)
        end
    end

    def name
      @name ||= tl.is_a?(I18n::MissingTranslation) ? tl.message : tl[badge_id][:name]
    end

    def desc
      @desc ||=
        unless tl.is_a?(I18n::MissingTranslation) || !tl[badge_id].key?(:desc)
          tl[badge_id][:desc]
        else
          I18n.t("achiever.achievements.#{achievement}.desc", count: required)
        end
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

# frozen_string_literal: true

module Achiever
  class Badge
    def self.from_attr(attr)
      attr.transform_keys(&:to_sym).yield_self do |a|
        Badge.new(a[:achievement], a[:required], a[:have])
      end
    end

    attr_accessor :attr

    %i[name desc img type visibility required have achievement achieved]
      .each do |k|
      define_method(k) do
        @attr[k]
      end
    end

    def initialize(name, required, have)
      @attr = {
        name: I18n.t("achievements.#{name}.badges.#{required}.name"),
        desc: I18n.t("achievements.#{name}.desc", count: required),
        img: Achiever.badge_attr(name, required)['img'],
        visibility: Achiever.achievement(name)['visibility'],
        required: required,
        have: have,
        achievement: name,
        achieved: have >= required
      }
    end

    def icon
      <<~BADGE
        <div class="badge_icon">
          <span
            class="#{achieved ? 'achieved' : 'unachieved'} #{img}"
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

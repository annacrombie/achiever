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
      cfg = Achiever.achievement(name)
      badge_id = cfg[:badges].index { |b| b[:required] == required }

      @attr = {
        name: I18n.t("achiever.achievements.#{name}.badges")[badge_id][:name],
        desc: I18n.t("achiever.achievements.#{name}.desc", count: required),
        img: cfg[:badges][badge_id][:img],
        visibility: cfg['visibility'],
        required: required,
        have: have,
        achievement: name,
        achieved: Achiever.attained?(name, required, have)
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

module Achiever
  module TranslationHelper
    module_function

    def badge(ach, id, field, **opts)
      a_tl("achiever.achievements.#{ach}.badges", id, field) do
        achievement(ach, field, **opts)
      end
    end

    def achievement(ach, field, **opts)
      check_tl("achiever.achievements.#{ach}.#{field}", opts) do
        default(field, **opts)
      end
    end

    def default(field, **opts)
      check_tl("achiever.defaults.#{field}", opts)
    end

    def a_tl(key, id, field, &block)
      tl = catch(:exception) { I18n.t(key, throw: true) }

      unless tl.is_a?(I18n::MissingTranslation) || !tl[id].key?(field)
        tl[id][field]
      else
        block_given? ? yield : ''
      end
    end

    def check_tl(key, **opts, &block)
      tl = catch(:exception) { I18n.t(key, **opts.merge(throw: true)) }

      unless tl.is_a?(I18n::MissingTranslation)
        tl
      else
        block_given? ? yield : tl.message
      end
    end
  end
end

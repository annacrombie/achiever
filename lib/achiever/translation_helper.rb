module Achiever
  # A I18n extension that allows for multiple fallback translations
  module TranslationHelper
    module_function

    # Translate a badge field
    #
    # If the field is missing, fallback to the badge's achievment
    #
    # @param ach [Symbol] the achievement name
    # @param id [Integer] the badge's id
    # @param field [Symbol] the field to translate
    # @param opts [Hash] only used if the fallback is called
    def badge(ach, id, field, **opts)
      a_tl("achiever.achievements.#{ach}.badges", id, field) do
        achievement(ach, field, **opts)
      end
    end

    # Translate an achievement field
    #
    # If the field is missing, fallback to defaults
    #
    # @param ach [Symbol] the achievement name
    # @param field [Symbol] the field to translate
    # @param opts [Hash] added to the call to I18n.t
    def achievement(ach, field, **opts)
      check_tl("achiever.achievements.#{ach}.#{field}", opts) do
        default(field, **opts)
      end
    end

    # Translate an default field
    #
    # If the field is missing, I18n will handle it
    #
    # @param field [Symbol] the field to translate
    # @param opts [Hash] added to the call to I18n.t
    def default(field, **opts)
      check_tl("achiever.defaults.#{field}", opts)
    end

    # Find a translation when the call to I18n.t will return an array of
    # objects, calling the supplied block if none is found
    #
    # @param key the key
    # @param id the index to pick in the array
    # @param field the field to pick of the object
    # @param block will be called if there is no translation found
    def a_tl(key, id, field, &block)
      tl = catch(:exception) { I18n.t(key, throw: true) }

      unless tl.is_a?(I18n::MissingTranslation) || !tl[id].key?(field)
        tl[id][field]
      else
        block_given? ? yield : ''
      end
    end

    # Find a translation, calling the supplied block if none is found
    #
    # @param key the key
    # @param field the field to pick of the object
    # @param block will be called if there is no translation found
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

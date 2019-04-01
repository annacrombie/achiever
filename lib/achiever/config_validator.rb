module Achiever
  module ConfigValidator
    VISIBILITIES = %w[hidden visible].freeze

    class EnumValidator < HashValidator::Validator::Base
      def initialize(name, allowed)
        @allowed = allowed
        super(name)
      end

      def validate(key, value, validations, errors)
        unless @allowed.include?(value)
          errors[key] = "expected one of #{@allowed}, got #{value.inspect}"
        end
      end
    end

    class BadgeRequirementsValidator < HashValidator::Validator::Base
      include ConfigValidator

      def initialize
        super('badge_requirements')
      end

      def validate(key, value, validations, errors)
        unless (value.is_a?(Array) && value.all? { |e| e.is_a?(String) }) ||
          [Integer, String].include?(value.class)
          errors[key] = 'expected an Integer, String, or an Array of strings'
        end
      end
    end

    class SlotsValidator < HashValidator::Validator::Base
      include ConfigValidator

      def initialize
        super('slots')
      end

      def validate(key, value, validations, errors)
        unless value.is_a?(Array) && value.all? { |e| e.is_a?(String) }
          errors[key] = 'expected an Array of strings'
        end
      end
    end

    class BadgesValidator < HashValidator::Validator::Base
      include ConfigValidator

      def initialize
        super('badges')
      end

      def validate(key, value, validations, errors)
        return errors[key] = presence_error_message if value.nil?
        return errors[key] = 'expected a Array' unless value.is_a?(Array)

        value.each do |v|
          bdg = HashValidator.validate(
            v,
            {
              required: 'badge_requirements',
              visibility: optional('visibility'),
              img: optional('string')
            },
            true
          )

          errors[key] = bdg.errors unless bdg.valid?
        end
      end
    end

    class AchievementsValidator < HashValidator::Validator::Base
      include ConfigValidator

      def initialize
        super('achievements')
      end

      def validate(key, value, validations, errors)
        return errors[key] = presence_error_message if value.nil?
        return errors[key] = 'expected a Hash' unless value.is_a?(Hash)

        value.each do |k, v|
          return errors[key] = { k => 'expected a Hash' } unless v.is_a?(Hash)

          ach = HashValidator.validate(
            v,
            {
              badges: 'badges',
              type: optional('type'),
              visibility: optional('visibility'),
              slots: optional('slots'),
            },
            true
          )

          errors[key] = { k => ach.errors } unless ach.valid?
        end
      end
    end

    [ AchievementsValidator.new,
      BadgesValidator.new,
      SlotsValidator.new,
      EnumValidator.new('type', Types::TYPES),
      EnumValidator.new('visibility', VISIBILITIES),
      BadgeRequirementsValidator.new ].each { |v| HashValidator.append_validator(v) }

    module_function

    def optional(validation)
      HashValidator.optional(validation)
    end

    def valid?(hash)
      validate(hash).valid?
    end

    def validate(hash)
      HashValidator.validate(hash, VALIDATIONS, true)
    end

    def valid!(hash)
      v = validate(hash)
      raise(Exceptions::InvalidConfig, v.errors) unless v.valid?
    end

    VALIDATIONS = {
      config: optional(
        defaults: optional(
          achievement: optional(
            desc: optional('string'),
            type: optional('type'),
            visibility: optional('visibility')
          ),
          badge: optional(
            img: optional('string')
          )
        )
      ),
      achievements: 'achievements'
    }
  end
end

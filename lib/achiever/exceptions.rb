# frozen_string_literal: true

module Achiever
  module Exceptions
    class InvalidAchievementName < StandardError
      def initialize(name)
        super("Invalid achievement name: '#{name}'")
      end
    end

    module InvalidConfig
      class WrongType < StandardError
        def initialize(thing, type)
          super("got #{thing} (#{thing.class}), expected #{type}")
        end
      end

      class MissingKey < StandardError
        def initialize(key, loc)
          super("the key #{key.inspect} missing at #{loc}")
        end
      end

      class ExtraKey < StandardError
        def initialize(key, loc)
          super("the key #{key.inspect} is invalid at #{loc}")
        end
      end

      class SlotError < StandardError
        def initialize(msg)
          super(msg)
        end
      end
    end
  end
end

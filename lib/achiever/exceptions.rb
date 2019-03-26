# frozen_string_literal: true

module Achiever
  module Exceptions
    class InvalidAchievementName < StandardError
      def initialize(name)
        super("Invalid achievement name: '#{name}'")
      end
    end

    class InvalidSlot < StandardError
      def initialize(slot)
        super("The slot #{slot} is not valid")
      end
    end

    class InvalidConfig < StandardError
      def initialize(errors)
        super(hash_to_s(errors))
      end

      def hash_to_s(hash, pre = '')
        hash.map do |k, v|
          case v
          when Hash
            hash_to_s(v, "#{pre}[#{k}]")
          else
            "#{pre}[#{k}] - #{v}"
          end
        end.join("\n")
      end
    end
  end
end

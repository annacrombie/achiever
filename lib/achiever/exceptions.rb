# frozen_string_literal: true

module Achiever
  module Exceptions
    class NoSuchBadge < StandardError; end

    class MissingArgToPartial < StandardError
      def initialize(arg)
        super("you forgot to pass '#{arg}' to the partial")
      end
    end

    class UninitializedAchieverSubject < StandardError
      def initialize
        super('no achiever subject set, please call set_achiever_subject(subject)')
      end
    end

    class InvalidAchievementName < StandardError
      def initialize(name)
        dict =
          DidYouMean::SpellChecker.new(dictionary: Achiever.achievements.keys)
        candidate = dict.correct(name)
        dym = candidate.empty? ? '' : ", did you mean #{candidate[0].inspect}?"

        super("Invalid achievement name: #{name.inspect}#{dym}")
      end
    end

    class InvalidSlot < StandardError
      def initialize(slot, slots)
        dict =
          DidYouMean::SpellChecker.new(dictionary: slots)
        candidate = dict.correct(slot)
        dym = candidate.empty? ? '' : ", did you mean #{candidate[0].inspect}?"

        super("The slot #{slot} is not valid#{dym}")
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

    class InvalidTrackerMethod < StandardError
      def initialize(meth)
        super("the method #{meth.inspect} is invalid")
      end
    end

    class TrackerArityTooLarge < StandardError
      def initialize(tracker)
        super("the tracker block for '#{tracker}' takes too many arguments")
      end
    end

    class InvalidSubject < StandardError
      def initialize
        super(<<~ERR)
          The object that implements Achiever::Subject must
            > be a descendant of ApplicationRecord
            > have a primary key of type :integer
        ERR
      end
    end

    class InvalidTrackerSubject < StandardError
      def initialize(obj)
        super("the object #{obj.inspect} is not a valid subject")
      end
    end
  end
end

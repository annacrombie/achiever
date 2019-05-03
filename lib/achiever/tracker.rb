module Achiever
  TRACKING_METHOD = :before_save
  # A module intended to be included in an ActiveRecord::Observer
  #
  # it allows for a clean dsl to track attribute changes of a model and apply
  # achievements based on those changes
  module Tracker
    class<<self
      # Add the track class method, as well as a subject instance method unless
      # one exists
      def append_features(rcvr)
        super

        unless rcvr.instance_methods.include?(:subject)
          rcvr.define_method(:subject) { |obj| obj }
        end

        rcvr.define_method(TRACKING_METHOD) { |*args| invoke_trackers(*args) }

        rcvr.define_singleton_method(:tracking_method) do |meth|
          rcvr.remove_method(TRACKING_METHOD)
          rcvr.define_method(meth) { |*args| invoke_trackers(*args) }
        end

        class<<rcvr

          # Track a change.  If the change occurs, the block will be called
          #
          # Methods for tracking change are
          # - +:new+ - fired every time there is a change, the given block is
          #   passed the new value
          # - +:existence+ - fired every time the new value is not nil, the
          #   given block is passed the new value
          # - +:truthy+ - fired every time the new value is true, the given
          #   block is passed the new value
          # - +:both+ - fired every time there is a change, the given block is
          #   passed the old and new values
          #
          # @param change can be a Hash or a Symbol.  If it is a Hash, only the
          #   first key and value will be considered.  The value will be what
          #   will be tracked, and the key will be the method used to track.  If
          #   it is a Symbol the method will default to +:new+
          #
          #       track :coins
          #
          #   will track the couns attribute of whatever the Observer is
          #   observing
          #
          #       track truthy: :signed_in
          #
          #   will track the signed_in attribute, but will only call the
          #   block if the attribute is changed to a truthy value
          # @param block the block that will be called when a change is triggered.
          #   Depending on the block's arity, it will be passed different arguments.
          #
          #   A block with arity of 0 will not be passed any arguments
          #   A block with arity of 1 will be passed *[subject]
          #   A block with arity of 2 will be passed *[subject, value]
          #   A block with arity of 3 will be passed *[subject, object, value]
          #
          #   Where subject is the result of calling #subject(object)
          #
          #   Where value is determined by the tracking method
          #
          #   Where object is the original object passed to the #before_save method,
          #     an instance of what this Tracker is tracking
          def track(change, &block)
            @tracking ||= {}

            if change.is_a?(Hash)
              method, change = change.to_a[0]
            else
              method = :new
            end


            @tracking[change.to_s] = {
              method: method,
              block: block
            }
          end

          attr_reader :tracking
        end
      end
    end

    # If you include this module into an ActiveRecord::Observer, this function
    # will be called automatically before whatever it is observing is saved.
    # This is the entrypoint for Tracker.
    #
    # You probably shouldn't call this directly
    def invoke_trackers(obj)
      subj = subject(obj)

      unless subj.class.included_modules.include?(Achiever::Subject)
        raise(Exceptions::InvalidTrackerSubject, subj)
      end

      return if subj.new_record?

      obj.changes_to_save.each do |k, v|
        next unless self.class.tracking.key?(k)

        self.class.tracking[k].tap do |t|
          change =
            case t[:method]
            when :new
              v[1]
            when :existence
              v[1].nil? ? next : v[1]
            when :truthy
              v[1] == true ? v[1] : next
            when :both
              v
            else
              raise(Achiever::Exceptions::InvalidTrackerMethod, t[:method])
            end

          args =
            case t[:block].arity.abs
            when 0
              []
            when 1
              [subj]
            when 2
              [subj, change]
            when 3
              [subj, obj, change]
            else
              raise(Achiever::Exceptions::TrackerArityTooLarge, k)
            end

          instance_exec(*args, &t[:block])
        end
      end
    end
  end
end

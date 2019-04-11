module Achiever
  module Tracker
    class<<self
      def append_features(rcvr)
        super

        unless rcvr.instance_methods.include?(:get_subj)
          rcvr.define_method(:get_subj) { |obj| obj }
        end

        class<<rcvr
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

    def before_save(obj)
      subj = get_subj(obj)
      return if subj.id.nil? # this is a brand new record

      obj.changes_to_save.each do |k, v|
        next unless self.class.tracking.key?(k)

        self.class.tracking[k].tap do |t|
          change =
            case t[:method]
            when :new
              v[1]
            when :existence
              v[1].nil? ? nil : v[1]
            when :truthy
              v[1] == true ? v[1] : nil
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

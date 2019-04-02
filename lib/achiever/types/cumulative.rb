module Achiever
  module Types
    module Cumulative
      extend Types::Base

      def check_progress(prog)
        prog = prog.nil? ? 1 : prog
        Achiever::Util.check_type(prog, Integer)
        prog
      end

      def overall_progress
        max = cfg[:badges].max_by { |e| e[:required] }
        [progress, max[:required]]
      end

      def achieved?(reqd, prog = nil)
        prog ||= progress
        prog >= reqd
      end

      def schedule(prog, on)
        Achiever::Util.check_type(on, Date)

        ScheduledAchievement.create(
          achievement_id: id,
          due: on,
          payload: check_progress(prog)
        )
      end

      def achieve(prog = nil)
        new_prog = check_progress(prog)
        achieve_raw(new_prog)
        self
      end

      def achieve_raw(prog)
        update(progress: self[:progress] + prog)
      end
    end
  end
end

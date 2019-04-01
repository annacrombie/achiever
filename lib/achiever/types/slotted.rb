module Achiever
  module Types
    module Slotted
      extend Types::Base

      def check_progress(prog)
        Util.check_type(prog, Symbol)
        Util.check_slot(prog, cfg[:slots])
        prog
      end

      def overall_progress
        [Logic.progress_to_slot_indices(progress), cfg[:slots]].map(&:count)
      end

      def achieved?(reqd, prog = nil)
        prog ||= progress
        reqd & prog == reqd
      end

      def schedule(prog, on)
        Util.check_type(on, Date)

        prog =
          Logic.slot_to_progress(cfg[:slots], check_progress(prog))

        ScheduledAchievement.create(
          achievement_id: id,
          due: on,
          payload: prog
        )
      end

      def achieve(prog)
        new_prog = Logic.slot_to_progress(cfg[:slots], check_progress(prog))
        achieve_raw(new_prog)
        self
      end

      def achieve_raw(prog)
        update(progress: self[:progress] | prog)
      end
    end
  end
end

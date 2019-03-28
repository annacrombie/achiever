module Achiever
  module Logic
    module_function

    def attained?(name, reqd, have)
      cfg = Achiever.achievement(name)
      case cfg[:type]
      when 'slotted'
        reqd & have == reqd
      when 'accumulation'
        have >= reqd
      end
    end

    def slots_to_required(all_slots, rqd_slots)
      all_slots.each_with_index.map do |e, i|
        i + 1 if rqd_slots.include?(e)
      end.compact.reduce(0) { |m, v| m + (2 ** v) }
    end

    def slot_to_progress(slots, slot)
      2 ** (slots.index(slot) + 1)
    end

    def progress_to_slot_indices(have)
      return [] unless have.positive?

      arr = []
      while have > 0
        arr << (have & 0x000000001 == 1 ? true : false)
        have >>= 1
      end

      arr[1..-1].each_with_index.map { |e, i| i if e }.compact
    end

    def slotted_progress(old, slots, slot)
      old | slot_to_progress(slots, slot)
    end

    def cumulative_progress(old, inc)
      old + inc
    end

    def overall_progress(name, have)
      cfg = Achiever.achievement(name)
      max = cfg[:badges].max_by { |e| e[:required] }

      case cfg[:type]
      when 'slotted'
        [progress_to_slot_indices(have), cfg[:slots]].map(&:count)
      when 'accumulation'
        [have, max[:required]]
      end
    end
  end
end

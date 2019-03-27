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

    def slotted_progress(old, slots, slot)
      old | slot_to_progress(slots, slot)
    end

    def cumulative_progress(old, inc)
      old + inc
    end
  end
end

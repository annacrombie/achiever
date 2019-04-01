module Achiever
  module Logic
    module_function

    def slots_to_required(all_slots, rqd_slots)
      all_slots.map.with_index do |e, i|
        i + 1 if rqd_slots.include?(e)
      end.compact.reduce(0) { |m, v| m + (2**v) }
    end

    def slot_to_progress(slots, slot)
      2**(slots.index(slot) + 1)
    end

    def progress_to_slot_indices(have)
      return [] unless have.positive?

      arr = []
      while have.positive?
        arr << (have & 0x000000001 == 1)
        have >>= 1
      end

      arr[1..-1].map.with_index { |e, i| i if e }.compact
    end
  end
end

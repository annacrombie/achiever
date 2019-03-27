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
  end
end

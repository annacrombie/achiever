require 'achiever/types/base'
require 'achiever/types/cumulative'
require 'achiever/types/slotted'

module Achiever
  module Types
    TYPES = %w[cumulative slotted]

    module_function

    def mod(type)
      case type
      when 'cumulative'
        Cumulative
      when 'slotted'
        Slotted
      end
    end
  end
end

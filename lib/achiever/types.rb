require 'achiever/types/base'
require 'achiever/types/cumulative'
require 'achiever/types/slotted'

module Achiever
  # Namespace for achiever type implementations
  module Types
    # The possible types
    TYPES = %w[cumulative slotted]

    module_function

    # Given a type, return its corresponding implementation module
    #
    # @param [String] type the type
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

module Achiever
  # Utility module for acheiever
  module Util
    module_function

    # Acts like include, but can be called on an instance of an object.  This
    # is slower because it defines new methods every time an object is
    # initialized but it provides for greater flexibility.
    #
    # @param rcvr the receiver to add methods to
    # @param mod [Module] the module to add methods from
    def instance_include(rcvr, mod)
      mod.instance_methods(false).each do |m|
        meth = mod.instance_method(m).bind(rcvr)

        rcvr.define_singleton_method(m, &meth)
      end
    end

    # Checks the type of an argument
    #
    # @raise TypeError unless +given.is_a?(expected)+
    #
    # @param given any value
    # @param expected the expected type
    def check_type(given, expected)
      raise(
        TypeError,
        "expected #{expected}, got #{given}:#{given.class}"
      ) unless given.is_a?(expected)
    end

    # Check if a given slot is in the list of possible slots
    #
    # @raise Exceptions::InvalidSlot unless +slots.include?(given)+
    def check_slot(given, slots)
      raise(
        Exceptions::InvalidSlot.new(given.inspect, slots)
      ) unless slots.include?(given)
    end

    # Convert all keys in hash to symbols, also convert all strings in arrays
    # to symbols
    #
    # @param [Hash] the hash to symbolize
    def deep_keys_to_sym(hash)
      hash.map do |k, v|
        [
          k.to_sym,
          case v
          when Hash
            deep_keys_to_sym(v)
          when Array
            v.map { |e| e.is_a?(Hash) ? deep_keys_to_sym(e) : e }
          else
            v
          end
        ]
      end.to_h
    end
  end
end


module Achiever
  module Util
    module_function

    def check_type(given, expected, context="")
      raise(
        TypeError,
        "expected #{expected}, got #{given}:#{given.class}"
      ) unless given.is_a?(expected)
    end

    def check_slot(given, slots)
      raise(
        Exceptions::InvalidSlot,
        "#{given.inspect}"
      ) unless slots.include?(given)
    end

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


module Achiever
  module Util
    module_function

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


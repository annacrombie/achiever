module Helpers
  def cf(base)
    File.join(__dir__, '../achiever/configs', base)
  end

  def load_yaml(path)
    Achiever::Util.deep_keys_to_sym(
      YAML.load(
        File.read(
          cf(path))))
  end

  def deep_keys_to_s(hash)
    hash.map do |k, v|
      [
        k.to_s,
        case v
        when Hash
          deep_keys_to_s(v)
        when Array
          v.map { |e| e.is_a?(Hash) ? deep_keys_to_s(e) : (e.is_a?(Symbol) ? e.to_s : e) }
        when Symbol
          v.to_s
        else
          v
        end
      ]
    end.to_h
  end
end

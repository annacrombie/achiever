module Helpers
  def cf(base)
    File.join(__dir__, '../configs', base)
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

  def make_tracker
    k = Class.new
    k.include(Achiever::Tracker)
    k
  end

  def fake_model(changes)
    obj = Class.new
    Achiever::Subject.append_features(obj, validate: false)
    obj.define_method(:id) { 1 }
    obj.define_method(:new_record?) { false }
    obj.define_method(:changes_to_save) { changes.transform_keys(&:to_s) }
    obj.new
  end
end

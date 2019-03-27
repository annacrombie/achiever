module Helpers
  def cf(base)
    File.join(__dir__, '../achiever/configs', base)
  end

  def validate(path)
    Achiever::ConfigValidator.validate(
      Achiever::Util.deep_keys_to_sym(
        YAML.load(
          File.read(
            cf(path)))))
  end
end

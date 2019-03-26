module Helpers
  def cf(base)
    File.join(__dir__, '../achiever/configs', base)
  end

  def validate(path)
    Achiever::ConfigValidator.validate(YAML.load(File.read(cf(path))))
  end
end

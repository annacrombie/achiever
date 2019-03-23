module Helpers
  def cf(base)
    File.join(__dir__, '../achiever/configs', base)
  end

  def cwe(e)
    Achiever::Exceptions::InvalidConfig.const_get(e)
  end

  def ce(e)
    Achiever::Exceptions.const_get(e)
  end
end

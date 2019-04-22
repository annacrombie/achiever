module Achiever
  class ApplicationController < ::ApplicationController
    def achiever_subject
      send(Achiever.config.subject)
    end
  end
end

module Achiever
  class ApplicationController < ::ApplicationController
    def achiever_subject
      send(Achiever.config.subject_getter)
    end
  end
end

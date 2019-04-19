module Achiever
  class ApplicationController < ::ApplicationController
    def achiever_subject
      send(Achiever.subject_getter)
    end
  end
end

module Trackers
  class TestTracker < ActiveRecord::Observer
    include Achiever::Tracker
    observe User

    track :age do |subj, age|
      subj.achieve(:get_older) if age > 50
    end
  end
end

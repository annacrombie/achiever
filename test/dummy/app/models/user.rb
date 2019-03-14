class User < ApplicationRecord
  include Achiever::Helpers
  has_many :achievements
end

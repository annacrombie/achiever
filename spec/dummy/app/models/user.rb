# frozen_string_literal: true

class User < ApplicationRecord
  include Achiever::Helpers
  has_many :achievements
end

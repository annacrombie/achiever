class ApplicationController < ActionController::Base
  def current_user
    unless User.first.nil?
      User.first
    else
      User.create
    end
  end
end

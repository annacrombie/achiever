# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def current_user
    if User.first.nil?
      User.create
    else
      User.first
    end
  end
end

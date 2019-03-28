# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Achiever::AchieverHelper
  before_action :set_achiever_subject

  def set_achiever_subject
    self.achiever_subject = current_user
  end

  def current_user
    if User.first.nil?
      User.create
    else
      User.first
    end
  end
end

# frozen_string_literal: true

Rails.application.routes.draw do
  mount Achiever::Engine, at: '/achievements'
end

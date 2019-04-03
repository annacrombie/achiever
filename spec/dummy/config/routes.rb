# frozen_string_literal: true

Rails.application.routes.draw do
  get '/new_badges', to: 'new_badges_test#index'

  mount Achiever::Engine, at: '/achievements'
end

# frozen_string_literal: true

Achiever::Engine.routes.draw do
  root to: 'achievements#index'
  get 'achievements', to: 'achievements#index'
end

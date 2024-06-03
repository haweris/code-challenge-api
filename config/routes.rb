# frozen_string_literal: true

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  devise_for :users, scope: :user, skip: :all
  devise_scope :user do
    scope module: :users, as: :user, defaults: { format: :json }, controller: 'sessions' do
      post :sign_up, action: 'sign_up'
      post :sign_in, action: 'create'
      delete :sign_out, action: 'destroy'
      post :forgot_password
      patch :reset_password
      post :validate_link
    end
  end

  resources :users, only: %i[create update destroy], controller: 'users/base' do
    member do
      get '/detail', action: 'show'
    end
  end

  resources :articles, controller: 'articles'
end

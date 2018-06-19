# frozen_string_literal: true

Rails.application.routes.draw do

  mount_devise_token_auth_for "User", at: "users"
  as :user do
    # Define routes for User within this block.
  end
  get "/", to: "application#index", as: "home"
  resources :lots
end

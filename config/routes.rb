# frozen_string_literal: true

Rails.application.routes.draw do

  mount_devise_token_auth_for "User", at: "users" # Serve websocket cable requests in-process
  mount ActionCable.server => "/cable"
  as :user do
    # Define routes for User within this block.
  end
  resources :lots, except: [:new, :edit]
  resources :bids, only: [:create, :index, :destroy]
  resources :orders, only: [:create, :update]
  get "/api" => redirect("/swagger/dist/index.html?url=/apidocs/api-docs.json")
end

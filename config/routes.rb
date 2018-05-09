Rails.application.routes.draw do
  devise_for :users
  match 'login', to: 'user#login', via: [:get, :post], as: 'login'
  match 'sign-in', to: 'user#sign_in', via: [:get, :post], as: 'sign-in'
  match 'sign-up', to: 'user#sign_up', via: [:get, :post], as: 'sign-up'
  get '/', to: 'application#index', as: 'home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

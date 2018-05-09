Rails.application.routes.draw do
  devise_for :users
  get '/login', to: 'user#login', constraints: { path: /\w+/ }, as: 'show_request_data'
  get '/', to: 'application#index', as: 'home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

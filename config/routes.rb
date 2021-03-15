Rails.application.routes.draw do
  namespace :admin do
    get '/login', to: 'user_sessions#new'
    post '/login', to: 'user_sessions#create'
    post '/logout', to: 'user_sessions#destroy'
    get '/register', to: 'user#new'
    get '/dashboards', to: 'dashboards#index'
    resources :users
    resources :articles
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'articles#index'
end

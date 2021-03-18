Rails.application.routes.draw do
  namespace :admin do
    get '/login', to: 'user_sessions#new'
    post '/login', to: 'user_sessions#create'
    post '/logout', to: 'user_sessions#destroy'
    get '/register', to: 'users#new'
    post '/register', to: 'users#create'
    get '/dashboards', to: 'dashboards#index'
    resources :users do
      get :activate, on: :member
    end
    resources :articles
    resources :tags
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'articles#index'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
  end
end

Rails.application.routes.draw do
  namespace :admin do
    root to: 'articles#index'
    resources :articles
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'articles#index'
end

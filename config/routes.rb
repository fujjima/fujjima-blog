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
    resources :reset_passwords, only: %w[new create edit update]
    resources :articles do
      collection do
        post :upload_image
      end
    end
    resources :tags, only: %w[index] do
      post :update, on: :collection
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'articles#index'
  get '/:slug', to: 'articles#show'
  get '/career', to: 'articles#career'
  get '/question', to: 'articles#question'

  get '/archives/:year', to: 'articles#archives', constraints: { year: /\d{4}/ }

  get '/archives/:year/:month', to: 'articles#archives', constraints: {
    year: /\d{4}/,
    month: /\d{1,2}/
  }

  # タグの詳細画面はなく、記事のタグによる絞り込み機能のみがある
  get '/tags/:tag_name', to: 'articles#tags'

  # タグに関する画面はタグ一覧画面のみ
  resources :tags, only: %w[index]

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
  end
end

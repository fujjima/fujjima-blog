Rails.application.routes.draw do
  # 管理画面
  namespace :admin do
    # 認証関連
    get  '/login',    to: 'user_sessions#new'
    post '/login',    to: 'user_sessions#create'
    post '/logout',   to: 'user_sessions#destroy'

    # OAuth
    get  'auth/:provider/callback', to: 'user_sessions#omniauth_callback'
    get  'auth/failure',            to: redirect('/admin/login')
    get  'auth/:provider',          to: 'user_sessions#oauth', as: :auth_at_provider

    # ユーザー登録
    get  '/register', to: 'users#new'
    post '/register', to: 'users#create'

    get '/dashboards', to: 'dashboards#index'

    resources :users do
      get :activate, on: :member
    end

    resources :reset_passwords, only: %i[new create edit update]

    resources :articles do
      collection do
        post :upload_image
      end
    end

    resources :tags, only: %i[index] do
      post :update, on: :collection
    end
  end

  root to: 'articles#index'
  get '/question', to: 'articles#question'
  get '/:slug', to: 'articles#show', as: :article

  # TODO: クエリパラメータ方式か archives リソースへの変更を検討
  archive_constraints = { year: /\d{4}/, month: /\d{1,2}/ }.freeze
  get '/archives/:year',        to: 'articles#archives', constraints: archive_constraints, as: 'archives_by_year'
  get '/archives/:year/:month', to: 'articles#archives', constraints: archive_constraints, as: 'archives_by_month'

  # タグによる記事絞り込み（タグ詳細画面はなし）
  get '/tags/:tag_name', to: 'articles#tags', as: 'article_tags'
  resources :tags, only: %i[index]

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
end

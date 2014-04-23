class ActionDispatch::Routing::Mapper
  # For split routes to multiple files
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end
end

TipsterHero::Application.routes.draw do
  mount Bootsy::Engine => '/bootsy', as: 'bootsy'
  root 'home#index'

  devise_for :accounts, controllers: {
      registrations: 'subscribers/registrations',
      omniauth_callbacks: 'subscribers/omniauth_callbacks',
      sessions: 'subscribers/sessions',
      passwords: 'subscribers/passwords'
  }

  # Routes for Subscriber module without prefix
  scope module: :subscribers do
    controller :profile do
      get :my_profile, to: :show
      post :update_profile, to: :update
      post :change_password
    end
  end

  resource :payment, controller: 'payment', only: [:create] do
    collection do
      post :return
      get :cancel
      post :notify
    end
  end

  resource :cart, controller: 'cart', only: [:show] do
    post :add_tipster
    post :drop_tipster
    get :empty
  end

  scope path: '/subscribe', as: :subscribe do
    controller :subscribe do
      match :account, via: [:get, :post]
      match :shopping_cart, via: [:get, :post]
      match :change_tipster, via: [:get, :post]
      match :personal_information, via: [:get, :post]
      match :shared, via: [:get, :post]
      match :receive_methods, via: [:get, :post]
      match :payment, via: [:get, :post]
      match :welcome, via: [:get, :post]
      post :get_coupon_code
      post :success
      get '/checkout', to: :checkout
    end
  end

  resources :tips, only: [:index, :show] do
    collection do
      get :last
    end
  end
  resources :tipsters, only: [:index, :show] do
    member do
      get :profile
      get :detail_statistics
      get :last_tips
      get :description
    end
  end
  resource :subscription, controller: 'subscription', only: [:show] do
    match :add_tipster, via: [:get, :post]
    match :change, via: [:get, :post]
    post :update
    post :upgrade
    post :set_primary
  end

  get '/pricing' => 'home#pricing', as: :pricing

  post '/home/select_language' => 'home#select_language', as: :select_language
  get '/subscription/select/:id' => 'subscription#select_plan', as: :select_plan
  delete '/subscription/tipster/:id' => 'subscription#remove_inactive_tipster', as: :remove_inactive_tipster
  post '/subscription/select_free_plan' => 'subscription#select_free_plan', as: :select_free_plan


  # Rueta set route here
  get '/signup', to: 'static#signup'
  get '/list', to: 'static#list'
  get '/homepage', to: 'static#homepage'
  # END Rueta set route here

  get '/get_matches' => 'home#get_matches'
  #draw :backoffice
  #draw :admin


  # ==============================================================================
  # Livescore routes
  # ==============================================================================
  namespace :livescore do
    root 'home#index'
    get ':sport_code', to: 'sports#filter', as: :sport
    get ':sport_code/:competition-:competition_id/', to: 'sports#filter'
  end

  # ==============================================================================
  # Backoffice Tipster routes
  # ==============================================================================
  devise_scope :account do
    namespace :backoffice do
      get '/sign_in', to: 'sessions#new', as: :sign_in
      post '/sign_in', to: 'sessions#create'
      get '/sign_out', to: 'sessions#destroy'
      get '/forgot_password', to: 'passwords#new', as: :forgot_password
      post '/forgot_password', to: 'passwords#new'
    end
  end

  namespace :backoffice do
    root 'home#index'
    get '/dashboard', to: 'home#dashboard'
    controller :profile do
      get :my_profile, to: :show
      post :update_profile, to: :update
      post :change_password
      post :change_avatar
      post :update_description
    end

    get 'my_tips', to: 'tips#my_tips'
    get 'my_statistics', to: 'home#my_statistics'

    resources :tips, except: [:index] do
      collection do
        post :confirm
      end
    end

    resources :matches, only: [:show] do
      member do
        get :find_bets
      end
      collection do
        get :search
        get :available
      end
    end

    get 'create-tip/available-matches', to: 'create_tip#available_matches', as: :bookmarker_matches
    get 'create-tip/search-matches', to: 'create_tip#search_matches', as: :search_bookmarker_matches
    get 'create-tip/manual', to: 'create_tip#search_matches', as: :manual_create_tip
    get 'create-tip/get-match-bets/:id', to: 'create_tip#get_match_bets', as: :get_match_bets
    post 'create-tip/confirm', to: 'create_tip#confirm', as: :confirm_create_tip
    post 'create-tip/submit', to: 'create_tip#submit', as: :submit_tip
    get 'create-tip/match-details/:id', to: 'create_tip#match_details', as: :match_details

  end

  # ==============================================================================
  # Backoffice Admin routes
  # ==============================================================================
  devise_scope :account do
    namespace :admin do
      get '/sign_in', to: 'sessions#new', as: :sign_in
      post '/sign_in', to: 'sessions#create'
      get '/sign_out', to: 'sessions#destroy'
    end
  end

  namespace :admin do
    root 'home#index'
    get '/dashboard', to: 'home#dashboard'
    controller :profile do
      get :my_profile, to: :show
      post :update_profile, to: :update
      post :change_password
    end


    resources :tipsters do
      member do
      end
    end

    resources :tips, only: [:show, :index] do
      collection do
        get :waiting
        get :published
      end
      member do
        post :publish # approved
        post :reject
        post :finish
      end
    end
  end
end

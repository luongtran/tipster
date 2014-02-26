TipsterHero::Application.routes.draw do
  root 'home#index'

  devise_for :subscribers, :controllers => {
      :registrations => "subscribers/registrations",
      :omniauth_callbacks => "subscribers/omniauth_callbacks",
      :sessions => "subscribers/sessions"
  }
  match '/my_profile' => 'profiles#my_profile', as: :my_profile, via: [:get, :post]

  # Routes for Subscriber module without prefix
  scope module: :subscribers do
    get '/my_account', to: 'accounts#show'
    post '/my_account', to: 'accounts#update'
    post '/change_password', to: 'accounts#change_password'
  end

  resource :payment, controller: 'payment', only: [:create] do
    collection do
      post :return
      get :cancel
      post :notify
      post :atos_notify
    end
  end

  resource :cart, controller: 'cart', :only => [:show] do
    post :add_tipster
    post :drop_tipster
  end

  scope path: '/subscribe', as: :subscribe do
    controller :subscribe do
      get :choose_offer
      get :add_offer
      match :identification, via: [:get, :post]
      match :payment_method, via: [:get, :post]
      match :payment, via: [:get, :post]
      match :atos_payment,via: [:get,:post]
      post :success
      post :get_coupon_code
      post :apply_coupon_code
      post :deny_coupon_code
    end
  end

  resources :tips, only: [:index, :show]

  # FIXME, there're many un-used routes
  resource :twitter, controller: 'twitter' do
    collection do
      get :tweet
      get :make
      post :return
    end
  end

  resources :tipsters, only: [:index, :show] do
    collection do
      get :top
      get :free
    end
  end

  resource :subscriptions, controller: 'subscriptions', :only => [:show] do
    post :update
  end

  get '/registration' => 'home#register', as: :registration
  post '/registration' => 'home#register', as: :registration_post

  get '/pricing' => 'home#pricing', as: :pricing

  get '/subscriptions/select/:id' => 'subscriptions#select_plan', as: :select_plan
  delete '/subscriptions/tipster/:id' => 'subscriptions#remove_inactive_tipster', as: :remove_inactive_tipster
  post '/subscriptions/select_free_plan' => 'subscriptions#select_free_plan', as: :select_free_pla

  # Backoffice Tipster routes ====================================================
  # Prefix: 'backoffice'
  namespace :backoffice do
    root 'home#index'
    get '/my_account', to: 'accounts#show'
    post '/my_account', to: 'accounts#update'
    post '/change_password', to: 'accounts#change_password'

    resources :tips

  end

  devise_for :tipsters, path: '/backoffice', :skip => :registrations, :controllers => {
      :sessions => "backoffice/sessions"
  }
  # End Tipster routes ===========================================================

  # Rueta set route here
  get '/signup', to: 'static#signup'
  # END Rueta set route here
end

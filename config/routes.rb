TipsterHero::Application.routes.draw do
  root 'home#index'

  devise_for :accounts, controllers: {
      registrations: 'subscribers/registrations',
      omniauth_callbacks: 'subscribers/omniauth_callbacks',
      sessions: 'subscribers/sessions'
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

  resource :cart, controller: 'cart', :only => [:show] do
    post :add_tipster
    post :drop_tipster
    get :empty
  end

  scope path: '/subscribe', as: :subscribe do
    controller :subscribe do
      get :choose_offer
      get :add_offer
      match :identification, via: [:get, :post]
      match :payment_method, via: [:get, :post]
      match :payment, via: [:get, :post]
      post :success
      post :get_coupon_code
      post :apply_coupon_code
      post :deny_coupon_code
    end
  end

  resources :tips, only: [:index, :show]
  resources :tipsters, only: [:index, :show]
  resource :subscriptions, controller: 'subscriptions', only: [:show] do
    post :update
    post :upgrade
  end

  get '/pricing' => 'home#pricing', as: :pricing
  post '/home/select_language' => 'home#select_language', as: :select_language
  get '/subscriptions/select/:id' => 'subscriptions#select_plan', as: :select_plan
  delete '/subscriptions/tipster/:id' => 'subscriptions#remove_inactive_tipster', as: :remove_inactive_tipster
  post '/subscriptions/select_free_plan' => 'subscriptions#select_free_plan', as: :select_free_plan

  # Backoffice Tipster routes ====================================================
  # Prefix: 'backoffice'
  devise_scope :account do
    namespace :backoffice do
      get '/sign_in', to: 'sessions#new', as: :backoffice_sign_in
      post '/sign_in', to: 'sessions#create'
      get '/sign_out', to: 'sessions#destroy'
    end
  end

  namespace :backoffice do
    root 'home#index'
    controller :profile do
      get :my_profile, to: :show
      post :update_profile, to: :update
      post :change_password
      post :change_avatar
      post :crop_avatar
    end
    resources :tips
  end

  # End Tipster routes ===========================================================

  # Rueta set route here
  get '/signup', to: 'static#signup'
  get '/homepage', to: 'static#homepage'
  # END Rueta set route here

  get '/test', to: 'home#xml_view', as: :list_match
end

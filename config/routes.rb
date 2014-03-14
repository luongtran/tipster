class ActionDispatch::Routing::Mapper
  # For split routes to multiple files
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end
end

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
      match :account, via: [:get, :post]
      match :choose_offer, via: [:get, :post]
      match :personal_information, via: [:get, :post]
      match :shared, via: [:get, :post]
      match :receive_methods, via: [:get, :post]
      match :payment, via: [:get, :post]
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
    end
    collection do
      get :fetch
      get :top_three
    end
  end
  resource :subscription, controller: 'subscription', only: [:show] do
    match :add_tipster, via: [:get, :post]
    post :update
    post :upgrade
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

  get '/test', to: 'home#xml_view', as: :list_match

  draw :backoffice
  draw :admin
end

TipsterHero::Application.routes.draw do
  root 'home#index'

  devise_for :users, :controllers => {
      :omniauth_callbacks => "users/omniauth_callbacks",
      :registrations => "users/registrations",
      :sessions => "users/sessions",
  }

  # TODO, the routes is just for testing
  resources :profiles, :only => [] do
    # show, update
  end

  match '/my_profile' => 'profiles#my_profile', as: :my_profile, via: [:get, :post]

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
  end

  scope path: '/subscribe', as: :subscribe do
    controller :subscribe do
      get :choose_offer
      match :identification, via: [:get, :post]
      match :payment_method, via: [:get, :post]
      match :payment, via: [:get, :post]
      post :success
    end
  end

  resource :twitter, controller: 'twitter' do
    get :tweet
  end

  resource :subscriptions, controller: 'subscriptions', :only => [:show] do
    post :update
  end
  get '/registration' => 'home#register', as: :registration
  post '/registration' => 'home#register', as: :registration_post

  get '/pricing' => 'home#pricing', as: :pricing
  get '/top_tipster' => 'tipsters#top_tipster', as: :top_tipster
  get '/subscriptions/select/:id' => 'subscriptions#plan_select', as: :select_subscription


end

TipsterHero::Application.routes.draw do
  root 'home#index'

  devise_for :users, :controllers => {
      :omniauth_callbacks => "users/omniauth_callbacks",
      :registrations => "users/registrations",
      :sessions => "users/sessions",
  }

  # TODO, the routes is just for testing
  resources :profiles, :except => [:index] do
    # show, update
  end

  resource :payment, controller: 'payment', only: [:create] do
    collection do
      get :success
      get :cancel
    end
  end

  resource :cart, controller: 'cart', :only => [:show] do
    post :add_tipster
    post :drop_tipster
  end

  get '/registration' => 'home#register', as: :registration
  post '/registration' => 'home#register', as: :registration_post

  get '/pricing' => 'home#pricing', as: :pricing
  get '/top_tipster' => 'tipsters#top_tipster', as: :top_tipster
  get '/subscriptions/select/:id' => 'subscriptions#plan_select', as: :select_subscription

  post '/subscriptions/ipn_notify' => 'subscriptions#ipn_notify', as: :ipn_notify


end

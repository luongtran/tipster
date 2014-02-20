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


  match '/register' => 'users/register#show', as: :register, via: [:get, :post]

  post '/register/identification' => 'users/register#identification', as: :identification_register

  post '/register/payment' => 'users/register#payment', as: :payment_register

  resource :subscriptions, controller: 'subscriptions', :only => [:show] do
    post :update
  end
  get '/registration' => 'home#register', as: :registration
  post '/registration' => 'home#register', as: :registration_post

  get '/pricing' => 'home#pricing', as: :pricing
  get '/top_tipster' => 'tipsters#top_tipster', as: :top_tipster
  get '/subscriptions/select/:id' => 'subscriptions#plan_select', as: :select_subscription


end

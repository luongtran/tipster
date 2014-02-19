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
      post :return
      get :cancel
      post :notify
    end
  end

  get '/pricing' => 'home#pricing', as: :pricing
  get '/top_tipster' => 'tipsters#top_tipster', as: :top_tipster
  get '/subscriptions/select/:id' => 'subscriptions#plan_select', as: :select_subscription
  post '/add_tipster_to_cart/:id' => 'carts#add_tipster', as: :add_tipster_to_cart
  post '/drop_tipster_from_cart/:id' => 'carts#drop_tipster', as: :drop_tipster_from_cart
  #Step 1
  get '/subscriptions/show' => 'subscriptions#show', as: :subscriptions_show
  #Step 2
  get '/subscriptions/identification' => 'subscriptions#identification', as: :subscriptions_identification
  #Step 3
  get '/subscriptions/payment' => 'subscriptions#payment', as: :subscriptions_payment
  #Step 4

end

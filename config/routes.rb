TipsterHero::Application.routes.draw do
  root 'home#index'

  devise_for :users, :controllers => {
      :omniauth_callbacks => "users/omniauth_callbacks",
      :registrations => "users/registrations",
      :sessions => "users/sessions",
  }

  get '/pricing' => 'home#pricing', as: :pricing
  get '/top_tipster' => 'tipsters#top_tipster',as: :top_tipster
  get '/subscriptions/select/:id' => 'subscriptions#plan_select', :as => :select_subscription
  post '/add_tipster_to_cart/:id' => 'carts#add_tipster', :as => :add_tipster_to_cart
  post '/drop_tipster_from_cart/:id' => 'carts#drop_tipster', :as => :drop_tipster_from_cart
  get '/cart/show' => 'carts#show', :as => :cart_show
end

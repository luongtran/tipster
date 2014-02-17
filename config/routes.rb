TipsterHero::Application.routes.draw do
  root 'home#index'

  devise_for :users, :controllers => {
      :omniauth_callbacks => "users/omniauth_callbacks",
      :registrations => "users/registrations",
      :sessions => "users/sessions",
  }

  get '/pricing' => 'subscription#index'
  get '/subscriptions/select/:id' => 'subscription#plan_select',:as => :select_subscription
end

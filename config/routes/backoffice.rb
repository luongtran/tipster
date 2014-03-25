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
    post :crop_avatar
  end
  get 'my_tips', to: 'tips#my_tips'
  resources :tips, except: [:index] do
  end
end
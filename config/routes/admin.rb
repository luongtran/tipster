# ==============================================================================
# Backoffice Admin routes
# ==============================================================================
devise_scope :account do
  namespace :admin do
    get '/sign_in', to: 'sessions#new', as: :sign_in
    post '/sign_in', to: 'sessions#create'
    get '/sign_out', to: 'sessions#destroy'
  end
end

namespace :admin do
  root 'home#index'
  get '/dashboard', to: 'home#dashboard'
  #controller :profile do
  #  post :change_password
  #end

  resources :tipsters, only: [:show] do
    member do
    end
  end

  resources :tips, only: [:show] do
    collection do
      get :waiting
      get :published
    end
    member do
      post :approved
      post :reject
    end
  end

end
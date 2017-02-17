Rails.application.routes.draw do
  root 'home#index'

  get 'oauths/oauth'

  get 'oauths/callback'

  resources :user_sessions, only: [:new, :destroy]
  resources :hellos, only: :index

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  post "oauth/callback" => "oauths#callback"
  get "oauth/callback" => "oauths#callback" # for use with Github, Facebook
  get "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider
end

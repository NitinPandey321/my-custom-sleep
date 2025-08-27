Rails.application.routes.draw do
  # Health check
  get "up", to: "rails/health#show", as: :rails_health_check

  # Authentication
  get    "/login",  to: "sessions#new"
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  get "/logout", to: "sessions#destroy"

  # Signup flow
  get  "/signup",          to: "users#role_selection"
  get  "/signup/client",   to: "users#new_client"
  get  "/signup/coach",    to: "users#new_coach"
  post "/signup/client",   to: "users#create_client"
  post "/signup/coach",    to: "users#create_coach"

  # config/routes.rb
  namespace :admin do
    resources :dashboard
    resources :users
    resources :plans
    resources :audit_logs, only: [ :index, :show ]
  end


  # Dashboards
  namespace :dashboards do
    get :client
    get :coach
    # get :admin
  end

  # Users
  resources :users, only: [ :show, :edit, :update ] do
    member do
      patch :change_password
    end
  end

  # Profile picture (singular resource since each user has one profile picture)
  resource :profile_picture, only: [ :show, :create, :destroy ]

  # Daily reflection (singular resource as well)
  resource :daily_reflection, only: [ :show, :create ]

  resources :passwords, only: [ :new, :create, :edit, :update ] do
    collection do
      get :verify_otp_form
      post :verify_otp
      post :resend_otp
    end
  end

  resources :plans do
    member do
      patch :upload_proof
      patch :approve
      patch :request_resubmission
    end
  end

  # Conversations + nested messages
  resources :conversations, only: [ :index, :show, :create ] do
    resources :messages, only: [ :create ]
  end

  # Root
  root "sessions#new"

  # PWA support (uncomment if needed)
  # get "manifest",        to: "rails/pwa#manifest",        as: :pwa_manifest
  # get "service-worker",  to: "rails/pwa#service_worker",  as: :pwa_service_worker
end

require "sidekiq/web"

Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  mount Sidekiq::Web => "/sidekiq"
  get "/oura/connect", to: "oura#connect"
  get "/oura/callback", to: "oura#callback"

  get "up", to: "rails/health#show", as: :rails_health_check
  match "/auth/:provider",          to: "omniauth#passthru", via: [ :get, :post ]
  match "/auth/:provider/callback", to: "sessions#oura",     via: [ :get, :post ]
  match "/auth/failure",            to: redirect("/"),       via: [ :get, :post ]

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
  get "users/verify_email", to: "users#verify_email", as: :verify_email

  # config/routes.rb
  namespace :admin do
    resources :dashboard
    resources :users
    resources :plans
    resources :audit_logs, only: [ :index, :show ]
    resources :exercise_gallery, only: [ :index ]
  end

  namespace :api do
    namespace :v1 do
      resource :sessions, only: [:create, :destroy]
      resource :registrations, only: [:create]
      resources :dashboard, only: [:index] do
        collection do
          get :coach_dashboard
        end
      end
      resources :plans, only: [:index, :create, :update] do
        collection do
          get :clients
        end
      end

      resources :conversations, only: [:index, :show] do
        member do
          post :escalate
          post :dismiss
          post :accept_request
          post :dismiss_request
          post :mark_as_read
        end

        collection do
          get :unread_count
        end

        resources :messages, only: [:index, :create]
      end
      resources :oura, only: [ :index ]

      resources :oura_auth, only: [] do
        collection do
          post :session
          get :connect
          get :callback
        end
      end

      resources :passwords, only: [] do
        collection do
          post :send_otp
          post :verify_otp
          post :reset
        end
      end
      resources :users, only: [ :show, :update ] do
        collection do
          put :change_password
        end
      end
    end
  end


  # Dashboards
  namespace :dashboards do
    get :client
    get :coach
    get :client_view_for_coach
    get :admin
    get :logs
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
      post :upload_proof
      post :mark_done
      patch :approve
      patch :request_resubmission
    end
  end

  # Conversations + nested messages
  resources :conversations, only: [ :index, :show, :create ] do
    member do
      post :escalate
      post :dismiss
      post :accept_request
      post :dismiss_request
    end
    resources :messages, only: [ :create ]
  end

  resources :oura_dashboard, only: [] do
    collection do
      get :dashboard_v2
      get :sleep_scores
    end
  end

  resources :exercise_gallery, only: [ :index ]
  resources :activity_logs, only: [:create]

  # Root
  root "sessions#new"
end

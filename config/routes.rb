Rails.application.routes.draw do
  get "dashboards/client"
  get "dashboards/coach"
  get "dashboards/admin"
  get "users/role_selection"
  get "users/new_client"
  get "users/new_coach"
  get "users/create_client"
  get "users/create_coach"
  get "sessions/new"
  get "sessions/create"
  get "sessions/destroy"

  resources :users, only: [ :show, :edit, :update ] do
    member do
      patch :change_password
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication routes
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # Sign up routes
  get "/signup", to: "users#role_selection"
  get "/signup/client", to: "users#new_client"
  get "/signup/coach", to: "users#new_coach"
  post "/signup/client", to: "users#create_client"
  post "/signup/coach", to: "users#create_coach"

  # Dashboard routes (placeholder for now)
  get "/client/dashboard", to: "dashboards#client"
  get "/coach/dashboard", to: "dashboards#coach"
  get "/admin/dashboard", to: "dashboards#admin"

  # Profile picture routes
  get "/profile-picture", to: "profile_pictures#show"
  post "/profile-picture", to: "profile_pictures#create"
  delete "/profile-picture", to: "profile_pictures#destroy"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "sessions#new"
  resources :plans do
    member do
      patch :upload_proof
      patch :approve
      patch :request_resubmission
    end
  end
  resources :conversations, only: [ :index, :show, :create ] do
    resources :messages, only: [ :create ]
  end
end

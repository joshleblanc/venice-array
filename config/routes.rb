Rails.application.routes.draw do
  # Root directs authenticated users to their gallery
  root to: "generation_arrays#index"

  # User registration
  resources :users, only: [ :new, :create ]
  resource :profile, only: [ :edit, :update ], controller: "users"

  # Users create a generation array, and we show its generations nested
  resources :generation_arrays, except: [ :edit, :update ] do
    member do
      get :copy
    end
    resources :generations, only: [ :index ]
  end
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end

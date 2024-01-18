Rails.application.routes.draw do
  resources :admin, only: [:index] do
    collection do
      get :components
      post :show_flash
    end
  end
  namespace :admin do
    resources :users do
      post "stop_impersonating", to: "users#stop_impersonating", on: :collection
      member do
        post "impersonate"
      end
    end
  end
  namespace :account do
    resource :password
  end
  resources :settings, only: [:index]

  devise_for :users, controllers: {
    registrations: "accounts/registrations",
    sessions: "accounts/sessions",
    passwords: "accounts/passwords",
    confirmations: "accounts/confirmations",
    unlocks: "accounts/unlocks"
  }
  devise_scope :user do
    namespace :accounts do
      post "/sign_in_as", to: "sessions#sign_in_as"
    end
  end
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
    resources :admin do
      collection do
        get :components
        post :show_flash
      end
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check
  get "/terms" => "terms_of_service#index"
  get "/dashboard" => "dashboard#index", as: :dashboard
  root "application#index"
end

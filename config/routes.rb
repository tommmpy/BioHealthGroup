Rails.application.routes.draw do
  # ============================================================================
  # Public pages
  # ============================================================================
  root "pages#home"
  get "up" => "rails/health#show", as: :rails_health_check

  # ============================================================================
  # Authentication
  # ============================================================================
  resource :session, only: [ :new, :create, :destroy ] do
    collection do
      get :choose
      post :recover
      post :force_new
    end
  end
  resources :passwords, param: :token, only: [ :new, :create, :edit, :update ]
  resources :registrations, only: %i[new create]

  # ============================================================================
  # User profile
  # ============================================================================
  resource :profile, only: [ :show, :edit, :update ]
  patch "profile/status", to: "profiles#update_status"

  # ============================================================================
  # Contact form
  # ============================================================================
  resource :contact, only: [ :create ]

  # ============================================================================
  # Dashboard
  # ============================================================================
  get "dashboard", to: "user_dashboards#index", as: :user_dashboard

  # ============================================================================
  # Chat conversations
  # ============================================================================
  resources :conversations, only: [ :index, :show, :new, :create, :edit, :update, :destroy ], controller: "chat/conversations" do
    resources :messages, only: [ :create ], controller: "chat/messages"
    member do
      patch :close
      patch :reopen
      patch :request_reopen
      patch :accept
    end
  end

  # ============================================================================
  # Notifications
  # ============================================================================
  resources :notifications, only: [ :index ] do
    collection do
      patch :mark_all_read
    end
    member do
      patch :mark_read
    end
  end

  # ============================================================================
  # Admin panel
  # ============================================================================
  namespace :admin do
    get "dashboard", to: "dashboard#index"

    resources :users

    resources :branches do
      member do
        patch :toggle_status
      end
    end

    resources :estudios do
      member do
        patch :iniciar
        patch :finalizar
        get :descargar_informe
      end
      collection do
        get :buscar_pacientes
      end
    end

    resources :hero_slides
    resources :process_steps
    resources :testimonials

    resources :activities, only: [ :index ]
  end
end

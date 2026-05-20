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
  get "/session", to: redirect("/session/new")
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
  # Staff panel (recepcionista, medico, operario, disenador, administrador)
  # ============================================================================
  namespace :staff do
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

    resources :appointments do
      member do
        patch :confirm
        patch :cancel
      end
      collection do
        get :buscar_pacientes
      end
    end

    resources :invoices do
      member do
        patch :mark_sent
        patch :mark_paid
        get :download_pdf
      end
      resources :payments, only: [ :index, :create ]
    end

    resources :production_orders do
      member do
        patch :start
        patch :complete
      end
    end
  end

  # ============================================================================
  # Admin panel (solo administrador)
  # ============================================================================
  namespace :admin do
    get "dashboard", to: "dashboard#index"

    resources :users do
      member do
        get :historial
      end
    end

    resources :branches do
      member do
        patch :toggle_status
      end
    end

    resources :hero_slides
    resources :process_steps
    resources :testimonials
    resources :products
    resources :activities, only: [ :index ]
  end

  # ============================================================================
  # API (JSON REST)
  # ============================================================================
  namespace :api do
    resource :session, only: [ :create, :destroy ]
    resources :estudios, only: [ :index, :show ]
    resource :profile, only: [ :show, :update ] do
      get :notifications, on: :collection
    end
    resources :conversations, only: [ :index, :show, :create ] do
      resources :messages, only: [ :create ]
    end
  end
end

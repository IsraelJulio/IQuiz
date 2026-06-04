Rails.application.routes.draw do
  root "dashboard#index"

  # Auth
  get  "login",  to: "sessions#new",     as: :login
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # Decks (Israel only for mutations)
  resources :decks do
    resources :cards, only: %i[new create edit update destroy]

    member do
      get  "import",          to: "decks#import_form"
      post "import",          to: "decks#import_process", as: nil
    end
  end

  # New deck from CSV (standalone)
  get  "import", to: "decks#import_new_form", as: :import_new_deck
  post "import", to: "decks#import_new_process"

  # Game sessions
  resources :game_sessions, only: %i[new create show] do
    member do
      post "answer"
    end
  end

  # Dashboard extras
  get "dashboard", to: "dashboard#index", as: :dashboard
  get "dashboard/day/:date", to: "dashboard#day", as: :dashboard_day

  # Goals
  resources :goals, only: %i[new create edit update destroy]
end

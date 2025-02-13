Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "", to: "home#index"
  resources :users
  resources :projects do
    resources :tasks do
      collection do
        get "status/:status", to: "tasks#status"
        get "overdue", to: "tasks#overdue"
      end
      resources :comments, only: [ :create, :update, :destroy ]
    end
  end
  get "tasks/report", to: "tasks#report"
  get "reports/status/:file_id", to: "reports#status"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end

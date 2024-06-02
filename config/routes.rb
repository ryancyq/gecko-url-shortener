Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "url#root"

  get "/url", to: "url#new", as: :new_url
  get "/url/:short_url_id", to: "url#show", as: :url
  post "/url", to: "url#create", as: :create_url

  get "/:slug", to: "url#redirect", as: :slug
end

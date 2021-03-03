require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'keyword#index'

  resources :keyword do
    member do
      get :one_scraping
    end
    collection do
      get :all_scraping
    end
  end

  resources :ad

  mount Sidekiq::Web => '/sidekiq'
end

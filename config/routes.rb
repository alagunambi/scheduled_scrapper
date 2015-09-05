require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do

  resources :schedules
  resources :tags
  resources :ads

  match "/schedule" => "visitors#schedule", via: :post

  mount Sidekiq::Web => '/sidekiq'

  root to: 'visitors#index'
end

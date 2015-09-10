require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do

  devise_for :admins
  resources :schedules
  resources :tags
  resources :ads

  match "/schedule" => "visitors#schedule", via: :post

  authenticate :admin do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: 'visitors#index'
end

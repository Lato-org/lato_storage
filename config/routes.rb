LatoStorage::Engine.routes.draw do
  root 'application#index'
  post 'cleaner', to: 'application#cleaner', as: :cleaner

  resources :blobs, only: [:index]
  resources :attachments, only: [:index]
  resources :variant_records, only: [:index]
end

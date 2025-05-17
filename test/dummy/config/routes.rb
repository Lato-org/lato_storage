Rails.application.routes.draw do
  mount Lato::Engine => "/lato"
  mount LatoStorage::Engine => "/lato_storage"

  root 'application#index'

  get 'documentation', to: 'application#documentation', as: :documentation

  # Products controller (Complete CRUD example)
  scope :products do
    get '', to: 'products#index', as: :products
    get 'autocomplete', to: 'products#index_autocomplete', as: :products_autocomplete
    get 'create', to: 'products#create', as: :products_create
    post 'create_action', to: 'products#create_action', as: :products_create_action
    get 'update/:id', to: 'products#update', as: :products_update
    patch 'update_action/:id', to: 'products#update_action', as: :products_update_action
    post 'export_action', to: 'products#export_action', as: :products_export_action
  end
end

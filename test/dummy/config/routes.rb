Rails.application.routes.draw do
  mount Lato::Engine => "/lato"
  mount LatoStorage::Engine => "/lato_storage"

  root 'application#index'

  get 'documentation', to: 'application#documentation', as: :documentation
end

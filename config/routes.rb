LatoStorage::Engine.routes.draw do
  root 'application#index'
  post 'cleaner', to: 'application#cleaner', as: :cleaner
end

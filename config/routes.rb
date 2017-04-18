Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  root 'static_pages#index'
  resources :games, only: [:index, :create, :show, :update, :new, :edit]
  resources :pieces, only: [:update]
end

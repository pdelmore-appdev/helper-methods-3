Rails.application.routes.draw do
  devise_for :users
  resources :actors
  resources :directors
  root "movies#index"
  
  resources :movies
end

Rails.application.routes.draw do
  resources :actors
  resources :directors
  root "movies#index"
  
  resources :movies
end

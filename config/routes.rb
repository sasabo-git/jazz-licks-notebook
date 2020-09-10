Rails.application.routes.draw do
  get 'home/index'
  root :to => 'home#index'
  resources :scores

  namespace "api" do
    resources :scores, only: %i(index create show update)
  end
end

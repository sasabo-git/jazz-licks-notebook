# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#index"

  devise_for :users, controllers: { registrations: "users/registrations",
                                    sessions: "users/sessions" }

  resources :users, only: [:show]
  resources :scores
  resources :private_scores, only: [:show]

  namespace "api", { format: "json" } do
    resources :scores, only: %i(index create show update)
    resources :private_scores, only: %i(create show)
  end
end

# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#index"

  devise_for :users, controllers: { registrations: "users/registrations",
                                    sessions: "users/sessions" }

  resources :users, only: [:show]
  resources :scores

  namespace "api", { format: "json" } do
    resources :scores, only: %i(index create show update)
  end
end

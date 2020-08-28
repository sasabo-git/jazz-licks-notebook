Rails.application.routes.draw do
  resources :scores

  namespace "api" do
    resources :scores, only: %i(index create show)
  end
end

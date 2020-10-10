# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  protected
    def after_sign_in_path_for(resource)
      user_path(resource)
    end

    def after_update_path_for(resource)
      current_user
    end
end

# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  protected
    def after_sign_up_path_for(resource)
      scores_path
    end

    def after_update_path_for(resource)
      current_user
    end

    def update_resource(resource, params)
      resource.update_without_password(params)
    end
end

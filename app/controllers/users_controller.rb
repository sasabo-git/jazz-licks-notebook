# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  before_action :set_user

  def show
  end

  private
    def set_user
      @user = User.find(params[:id])
    end
end

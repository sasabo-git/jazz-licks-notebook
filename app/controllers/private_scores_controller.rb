# frozen_string_literal: true

class PrivateScoresController < ApplicationController
  before_action :set_private_score, only: [:show, :destroy]

  def show
  end

  # 現状つかっていないが今後アカウントをもつユーザーで使う予定
  def destroy
    @private_score.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: "Score was successfully destroyed." }
    end
  end

  private
    def set_private_score
      @private_score = PrivateScore.find(params[:id])
    end
end

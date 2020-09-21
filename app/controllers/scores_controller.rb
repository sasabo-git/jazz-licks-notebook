# frozen_string_literal: true

class ScoresController < ApplicationController
  before_action :set_score, only: [:show, :edit, :destroy]
  before_action :authenticate_user!

  def index
    @scores = Score.all
  end

  def show
  end

  def destroy
    @score.destroy
    respond_to do |format|
      format.html { redirect_to scores_url, notice: "Score was successfully destroyed." }
    end
  end

  private
    def set_score
      @score = Score.find(params[:id])
    end

    def score_params
      params.require(:score).permit(:title, :body, :key, :meter, :chord_progression, :memo, :bpm)
    end
end

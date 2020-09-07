class ScoresController < ApplicationController
  before_action :set_score, only: [:show, :destroy]

  def index
    @scores = Score.all
  end

  def show
  end

  def destroy
    @score.destroy
    respond_to do |format|
      format.html { redirect_to scores_url, notice: 'Score was successfully destroyed.' }
    end
  end

  private
    def set_score
      @score = Score.find(params[:id])
    end

    def score_params
      params.require(:score).permit(:title, :body)
    end
end

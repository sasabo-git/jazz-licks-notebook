# frozen_string_literal: true

class Api::ScoresController < Api::BaseController
  include Rails.application.routes.url_helpers
  before_action :set_score, only: %i(show)

  def index
    scores = Score.all
    render json: scores
  end

  def show
    render json: @score
  end

  def create
    score = Score.new(score_params)
    if score.save
      render json: score, status: :created
    else
      head :bad_request
    end
  end

  private
    def set_score
      @score = Score.find(params[:id])
    end

    def score_params
      params.require(:score).permit(:title, :key, :body)
    end
end

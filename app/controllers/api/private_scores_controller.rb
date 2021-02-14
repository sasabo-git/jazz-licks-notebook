# frozen_string_literal: true

class Api::PrivateScoresController < Api::BaseController
  include Rails.application.routes.url_helpers

  def show
    target = PrivateScore.find(params[:id])
    # saved_idが存在するとき
    # => 関連する保存された譜面を返す(アカウントをもつユーザーの譜面を返す)
    @private_score = target.saved_id ? target.score : target
  end

  def create
    @private_score = PrivateScore.new(private_score_params)
    if @private_score.save
      render json: { status: :created, id: @private_score.id }
    else
      head :bad_request
    end
  end

  private
    def private_score_params
      params.require(:private_score).permit(:saved_id, :title, :body, :key, :meter, :chord_progression, :memo, :bpm)
    end
end

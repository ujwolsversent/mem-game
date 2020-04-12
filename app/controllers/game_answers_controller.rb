class GameAnswersController < ApplicationController
  before_action :find_or_create_game

  def index
  end

  def create
    answer = AnswerResource.build(params)
    answer.resource.user = current_user
    answer.resource.game = @game

    if answer.save
      render jsonapi: answer, status: 201
    else
      render jsonapi_errors: answer
    end
  end

  private

  # normally you wouldn't create a game on the fly
  # but we're trying to simplify demonstrating APIs
  def find_or_create_game
    @game = Game.find_or_create_by!(id: params[:game_id])
    # also add player to game
    unless @game.players.exists?(id: current_user.id)
      @game.players << current_user
    end
  end
end
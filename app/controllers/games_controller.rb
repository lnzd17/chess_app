class GamesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def new
    @game = Game.new
  end

  def create
    @game = current_user.games_as_white.create!(game_params.merge(white_player_id: current_user))
    @game.associate_pieces!(current_user, 'white')
    if @game.save
      flash[:notice] = 'You are the white player. You will be notified when a black player joines the game!'
      redirect_to game_path(@game)
    else
      render 'index', status: :unprocessable_entity
    end
  end

  def show
    @game = current_game
    respond_to do |format|
      format.json { render json: @game.pieces }
      format.html
    end
    # render the pieces on the board
  end

  def edit
    @game = current_game
  end

  def update
    @game = current_game
    current_user.games_as_black.merge!(game_params.update(black_player_id: current_user))
    # @game.update_attributes(game_params)
    @game.associate_pieces!(current_user, 'black')
    if @game.save
      flash[:notice] = 'You are the black player. The white player can now begin the game'
      redirect_to game_path(@game)
    else
      render 'index', status: :unprocessable_entity
    end
  end

  # add update, join, forefit, draw, check/checkmate(here or pieces controller/model), load-board functions

  private

  def game_params
    params.require(:game).permit(:name, :black_player_id)
  end

  def current_game
    @game ||= Game.find(params[:id])
  end
end

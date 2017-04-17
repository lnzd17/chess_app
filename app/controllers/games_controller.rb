class GamesController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]


  def new
    @game = Game.new
  end

  def index
    @games = Game.where(black_player_id: nil)
  end

  def create
    @game = current_user.games_as_white.create!(game_params.merge(white_player_id: current_user))
    @game.associate_pieces!(current_user, 'white')
    flash[:notice] = 'You are the white player. You will be notified when a black player joins the game!'
    redirect_to game_path(@game)
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = 'Something went wrong. Please try again!'
    redirect_to games_path
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
    if @game.black_player.nil? && current_user != @game.white_player
      @game.black_player_update!(current_user)
      flash[:notice] = 'You are the black player. The white player can now begin the game'
      redirect_to game_path(@game)
    else
      flash[:alert] = 'The game is full'
      render 'index', status: :unprocessable_entity
    end
  end

  def destroy
  end

  # add update, join, forefit, draw, check/checkmate(here or pieces controller/model), load-board functions

  private

  def game_params
    params.require(:game).permit(:name)
  end

  def current_game
    @game ||= Game.find(params[:id])
  end
end

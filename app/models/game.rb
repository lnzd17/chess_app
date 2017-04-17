class Game < ApplicationRecord
  has_many :pieces
  has_many :white_player, class_name: 'User', foreign_key: 'white_player_id'
  has_many :black_player, class_name: 'User', foreign_key: 'black_player_id'
  after_create :make_newboard

  validates :name, presence: true

  after_create :populate_board!, :first_turn!

  def find_piece(x_position, y_position)
    pieces.find_by(x_position: x_position, y_position: y_position)
    # need to add finding the color associated with it too, right?
  end

  def first_turn!
    update(turn: 'white', player_turn: 1)
  end

  def end_turn!(color)
    player_color = color == 'white' ? 'black' : 'white'
    increment!(:move_number)
    update(turn: player_color)
    game_over!(turn) if checkmate?(turn)
    draw! if stalemate?(turn)
  end

  def checkmate?(turn); end

  def check?(turn); end

  def stalemate?(turn); end

  def draw!(turn); end

  def game_over!(turn); end

  def game_played!
    white_player.increment!(:games_played)
    black_player.increment!(:games_played)
  end

  def make_newboard
    # create and place white pieces
    (0..7).each do |i|
      Pawn.create(game_id: id, x_position: i, y_position: 1, color: 'White', user_id: white_player_id)
    end

    Rook.create(game_id: id, x_position: 0, y_position: 0, color: 'White', user_id: white_player_id)
    Rook.create(game_id: id, x_position: 7, y_position: 0, color: 'White', user_id: white_player_id)
    Knight.create(game_id: id, x_position: 1, y_position: 0, color: 'White', user_id: white_player_id)
    Knight.create(game_id: id, x_position: 6, y_position: 0, color: 'White', user_id: white_player_id)
    Bishop.create(game_id: id, x_position: 2, y_position: 0, color: 'White', user_id: white_player_id)
    Bishop.create(game_id: id, x_position: 5, y_position: 0, color: 'White', user_id: white_player_id)
    Queen.create(game_id: id, x_position: 3, y_position: 0, color: 'White', user_id: white_player_id)
    King.create(game_id: id, x_position: 4, y_position: 0, color: 'White', user_id: white_player_id)

    # create and place black pieces
    (0..7).each do |i|
      Pawn.create(game_id: id, x_position: i, y_position: 6, color: 'Black', user_id: white_player_id)
    end

    Rook.create(game_id: id, x_position: 0, y_position: 7, color: 'Black', user_id: white_player_id)
    Rook.create(game_id: id, x_position: 7, y_position: 7, color: 'Black', user_id: white_player_id)
    Knight.create(game_id: id, x_position: 1, y_position: 7, color: 'Black', user_id: white_player_id)
    Knight.create(game_id: id, x_position: 6, y_position: 7, color: 'Black', user_id: white_player_id)
    Bishop.create(game_id: id, x_position: 2, y_position: 7, color: 'Black', user_id: white_player_id)
    Bishop.create(game_id: id, x_position: 5, y_position: 7, color: 'Black', user_id: white_player_id)
    Queen.create(game_id: id, x_position: 3, y_position: 7, color: 'Black', user_id: white_player_id)
    King.create(game_id: id, x_position: 4, y_position: 7, color: 'Black', user_id: white_player_id)
  end

  def associate_pieces!
    pieces.where(color: 'Black').update(user_id: black_player_id)
  end

  # scope method for determining which games do not have a black_player
  def self.with_one_player
    where(black_player_id: nil)
  end
  # from here first thing to do is create method for player joining a free game
  # where white player is already present so we need a JOIN method that focuses
  # on the black player since the game is created with the white player
end

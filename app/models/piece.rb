class Piece < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validates :color, presence: true
  validates :type, presence: true
  validates :x_position, presence: true
  validates :y_position, presence: true
  validates :game_id, presence: true
  validates :move_num, presence: true

  def valid_move?(x_new, y_new)
    on_board? && !friendly_piece(x_new, y_new)
  end

  def on_board?
    x_position >= 1 && x_position <= 8 && y_position >= 1 && y_position <= 8
  end

  def move(x_new, y_new)
    if valid_move?(x_new, y_new) && your_turn? && attack!(x_new, y_new) != false
      Piece.transaction do
        attack!(x_new, y_new)
        update!(x_position: x_new, y_position: y_new, move_num: move_num + 1)
        if game.check == color
          raise ActiveRecord::Rollback, 'Move forbidden: exposes king to check'
        end
      end
      game.next_turn
    end
  end

  def pusher_game_end
    unless Rails.env == 'test'
      Pusher.trigger("end-channel-#{game.id}", 'game-finished', {
        message: "#{game.player_turn} has lost the game in a #{game.outcome}!"
      })
    end
  end

  def obstructed?(x_new, y_new) # Integrate with color
    xdir = x_position < x_new ? 1 : ((x_position == x_new ? 0 : -1))
    ydir = y_position < y_new ? 1 : ((y_position == y_new ? 0 : -1))
    i = 1
    dx = (x_new - x_position).abs
    dy = (y_new - y_position).abs
    until i == [dx, dy].max
      if game.find_piece(x_position + i * xdir, y_position + i * ydir).present?
        return true
      end
      i += 1
    end
    false
  end

  def moved?
    updated_at != created_at
  end

  def toggle_move!
    update(moved: true) if moved_num > 0
  end

  def vertical_move?(x_new, y_new)
    x_position == x_new && y_position != y_new
  end

  def horizontal_move?(x_new, y_new)
    y_position == y_new && x_position != x_new
  end

  def diagonal_move?(x_new, y_new)
    x_diff(x_new) == y_diff(y_new)
  end

  def x_diff(x_new)
    (x_new - x_position).abs
  end

  def y_diff(y_new)
    (y_new - y_position).abs
  end

  def occupied?(x_new, y_new)
    opponent(x_new, y_new).nil? ? false : true
  end

  def opponent(x_new, y_new)
    game.find_piece(x_new, y_new)
  end

  def friendly_piece(x_new, y_new)
    game.pieces.find_by(x_position: x_new, y_position: y_new, color: color)
  end

  def attack!(x_new, y_new)
    if occupied?(x_new, y_new) && opponent(x_new, y_new).color != color
      opponent(x_new, y_new).update(captured: true, x_position: -1, y_position: -1)
    elsif !occupied?(x_new, y_new)
      true
    else
      false
    end
  end

  def your_turn?
    return false if game.player_turn != color
    true
  end
end

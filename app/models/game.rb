# this class needs to be an ActiveRecord in order for Cable Ready to broadcast to it *shrug*
class Game
  attr_accessor :id
  # session id of red player, nil if red player not yet present
  attr_accessor :red_player
  # session id of blue player, nil if blue player not yet present
  attr_accessor :blue_player
  # 2d array representing the board. contains either :empty, :red, or :blue
  attr_accessor :board
  # the next color to make a move
  attr_accessor :next_move
  # number of captures by the red player
  attr_accessor :red_captures
  # number of captures by the blue player
  attr_accessor :blue_captures

  def initialize(id)
    @id = id
    @board = Array.new(19) {Array.new(19) {:empty}}
    @next_move = :red
    @red_captures = 0
    @blue_captures = 0
  end
end
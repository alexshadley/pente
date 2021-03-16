require "redis_supplier"

class BoardReflex < ApplicationReflex
  DIRECTIONS = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]

  def join
    redis = RedisSupplier.get
    @game = Marshal.load(redis.get(params[:id]))

    session_id = session.id.to_s

    if element.dataset['color'] == 'red'
      @game.red_player = session_id
      puts 'setting red player'
    elsif element.dataset['color'] == 'blue'
      @game.blue_player = session_id
    end

    redis.set(params[:id], Marshal.dump(@game))
  end

  def play
    redis = RedisSupplier.get
    @game = Marshal.load(redis.get(params[:id]))

    if session.id.to_s == @game.red_player
      player = :red
      other = :blue
    elsif session.id.to_s == @game.blue_player
      player = :blue
      other = :red
    else
      # TODO: implement when spectators work
      throw Exception.new
    end

    # abort if it isn't the current player's turn
    if player != @game.next_move
      return
    end

    x = element.dataset["x"].to_i
    y = element.dataset["y"].to_i

    # abort if the space is already taken
    if @game.board[y][x] != :empty
      return
    end

    # move succeeds; update game and persist to redis
    @game.board[y][x] = player
    
    # handle captures
    for dir in DIRECTIONS
      if @game.board[y + dir[1]][x + dir[0]] == other &&
        @game.board[y + dir[1] * 2][x + dir[0] * 2] == other &&
        @game.board[y + dir[1] * 3][x + dir[0] * 3] == player

        @game.board[y + dir[1]][x + dir[0]] = :empty
        @game.board[y + dir[1] * 2][x + dir[0] * 2] = :empty

        if player == :red
          @game.red_captures += 1
        elsif player == :blue
          @game.blue_captures += 1
        else
          throw Exception.new
        end
      end
    end

    @game.next_move = @game.next_move == :red ? :blue : :red
    redis.set(params[:id], Marshal.dump(@game))

    #broadcast results to other players/spectators
    cable_ready["game:#{@game.id}"].morph(
      selector: "#board",
      html: render(partial: "board", locals: {game: @game})
    ).broadcast
  end
end
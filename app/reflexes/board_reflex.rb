require "redis_supplier"

class BoardReflex < ApplicationReflex
  DIRECTIONS = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]
  CAPTURES_TO_WIN = 5
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

    #broadcast results to other players/spectators
    cable_ready["game:#{@game.id}"].morph(
      selector: "#game-headings",
      html: render(partial: "game_headings", locals: {game: @game})
    ).broadcast
  end


  def checkWin(game, x, y, player)
    # check if current player has hit the capture needs
    if (player == :red && game.red_captures >= CAPTURES_TO_WIN) ||
       (player == :blue && game.blue_captures >= CAPTURES_TO_WIN)
      return true
    end

    x_max = game.board.length - 1
    y_max = game.board[0].length - 1
    up_consecutive = 0
    ur_consecutive = 0
    right_consecutive = 0
    dr_consecutive = 0
    down_consecutive = 0
    dl_consecutive = 0
    left_consecutive = 0
    ul_consecutive = 0
    up_consecutive += 1 while (y+up_consecutive+1).between?(0,y_max) && 
      game.board[y + up_consecutive + 1][x] == player
    ur_consecutive += 1 while (y+ur_consecutive+1).between?(0,y_max) && 
      (x+ur_consecutive+1).between?(0,x_max) &&
      game.board[y+ur_consecutive+1][x+ur_consecutive+1] == player
    right_consecutive += 1 while (x+right_consecutive+1).between?(0,x_max) && 
      game.board[y][x + right_consecutive + 1] == player
    dr_consecutive += 1 while (y-dr_consecutive-1).between?(0,y_max) && 
      (x+dr_consecutive+1).between?(0,x_max) &&
      game.board[y-dr_consecutive-1][x+dr_consecutive+1] == player
    down_consecutive += 1 while (y-down_consecutive-1).between?(0,y_max) && 
      game.board[y - down_consecutive - 1][x] == player
    dl_consecutive += 1 while (y-dl_consecutive-1).between?(0,y_max) && 
      (x-dl_consecutive-1).between?(0,x_max) &&
      game.board[y-dl_consecutive-1][x-dl_consecutive-1] == player
    left_consecutive += 1 while (x-left_consecutive-1).between?(0,x_max) && 
      game.board[y][x-left_consecutive-1] == player
    ul_consecutive += 1 while (y+ul_consecutive+1).between?(0,y_max) && 
      (x-ul_consecutive-1).between?(0,x_max) &&
      game.board[y+ul_consecutive+1][x-ul_consecutive-1] == player
    return (up_consecutive + down_consecutive >= 4) || (ur_consecutive + dl_consecutive >= 4) ||
      (left_consecutive + right_consecutive >= 4) || (dr_consecutive + ul_consecutive >= 4)
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

    # abort if it isn't the current player's 
    # turn or if the game is over
    if player != @game.next_move || !@game.winner.nil?
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
      # if three spaces away in this direction isn't on the board then we don't need to check for captures
      if x + dir[0] * 3 > 18 || x + dir[0] * 3 < 0 ||
        y + dir[1] * 3 > 18 || y + dir[1] * 3 < 0
        next
      end

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

    if checkWin(@game, x, y, player)
      @game.winner_id = session.id
      @game.winner = player
    end

    @game.next_move = @game.next_move == :red ? :blue : :red
    redis.set(params[:id], Marshal.dump(@game))

    #broadcast results to other players/spectators
    cable_ready["game:#{@game.id}"]
      .morph(
        selector: "#board",
        html: render(partial: "board", locals: {game: @game})
      )
      .morph(
        selector: "#game-headings",
        html: render(partial: "game_headings", locals: {game: @game})
      )
      .broadcast
  end

  def send_message(message)
    redis = RedisSupplier.get
    @game = Marshal.load(redis.get(params[:id]))

    if session.id.to_s == @game.red_player
      user = "Red"
    elsif session.id.to_s == @game.blue_player
      user = "Blue"
    else
      user = "Spectator"
    end

    @game.messages.append(Message.new(user, message))
    redis.set(params[:id], Marshal.dump(@game))

    #broadcast results to other players/spectators
    cable_ready["game:#{@game.id}"].morph(
      selector: "#chat-log",
      html: render(partial: "chat_log", locals: {game: @game})
    ).broadcast
  end
end
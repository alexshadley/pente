module GameHelper
  def GameHelper.broadcast_to_players(game, broadcast_fn)
    if !game.red_player.nil?
      broadcast_fn.call("game:#{game.id}:red", game.red_player)
    end
    if !game.blue_player.nil?
      broadcast_fn.call("game:#{game.id}:blue", game.blue_player)
    end

    # TODO: find something better to use as a spectator session id
    broadcast_fn.call("game:#{game.id}:spectator", "")
  end
end

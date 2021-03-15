require "redis_supplier"
require "json"
require "securerandom"

class GameController < ApplicationController
  def create
    redis = RedisSupplier.get

    game = Game.new(SecureRandom.urlsafe_base64(8))
    redis.set(game.id, Marshal.dump(game))

    redirect_to action: "show", id: game.id
  end

  def show
    redis = RedisSupplier.get

    serialized_game = redis.get(params[:id])
    @game = Marshal.load(serialized_game)

    session_id = session.id.to_s
    if @game.red_player.nil?
      @game.red_player = session.id.to_s
      redis.set(@game.id, Marshal.dump(@game))
    elsif @game.blue_player.nil? && session_id != @game.red_player
      @game.blue_player = session_id
      redis.set(@game.id, Marshal.dump(@game))
    end
  end
end

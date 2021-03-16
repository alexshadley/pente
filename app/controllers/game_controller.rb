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
  end
end

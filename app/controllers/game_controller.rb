require "redis_supplier"
require "json"
require "securerandom"
require "game_helper"

class GameController < ApplicationController
  include CableReady::Broadcaster

  def create
    redis = RedisSupplier.get

    game = Game.new(SecureRandom.urlsafe_base64(8))
    redis.set(game.id, Marshal.dump(game))

    previous_game_id = params[:previous]
    if !previous_game_id.nil?
      previous_game = Marshal.load(redis.get(previous_game_id))
      previous_game.next_game = game.id
      redis.set(previous_game_id, Marshal.dump(previous_game))

      # tell users in the preivous game about the new game
      GameHelper.broadcast_to_players(
        previous_game,
        ->(channel_id, session_id) {
          cable_ready[channel_id].morph(
            selector: "#game-headings",
            html: render_to_string(partial: "game_headings", locals: {game: previous_game, session_id: session_id})
          ).broadcast
        }
      )
    end

    redirect_to action: "show", id: game.id
  end

  def show
    redis = RedisSupplier.get

    serialized_game = redis.get(params[:id])
    @game = Marshal.load(serialized_game)
  end
end

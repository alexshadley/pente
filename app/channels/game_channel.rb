require "redis_supplier"

class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game:#{params[:id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

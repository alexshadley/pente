require "redis_supplier"

class GameChannel < ApplicationCable::Channel
  def subscribed
    if params[:player].nil?
      stream_from "game:#{params[:id]}"
    else
      stream_from "game:#{params[:id]}:#{params[:player]}"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

import CableReady from 'cable_ready'
import consumer from './consumer'

// javascript programmers eat your hearts out
var player_subscription

function get_player_from_document() {
  return document.getElementById('game-headings').getAttribute('data-player')
}

function subscribe() {
  consumer.subscriptions.create(
    {
      channel: 'GameChannel',
      id: document.URL.substring(document.URL.lastIndexOf('/') + 1)
    },
    {
      received (data) {
        if (data.cableReady) CableReady.perform(data.operations)
      }
    }
  )
}

export function update_subscription() {
  if (player_subscription) {
    consumer.subscriptions.remove(player_subscription)
  }

  var player = get_player_from_document()
  console.log('subscribing to: ' + player)
  player_subscription = consumer.subscriptions.create(
    {
      channel: 'GameChannel',
      id: document.URL.substring(document.URL.lastIndexOf('/') + 1),
      player: player
    },
    {
      received (data) {
        if (data.cableReady) CableReady.perform(data.operations)
      }
    }
  )
}

// subscribe once when the page loads
document.addEventListener("turbolinks:load", function() {
  subscribe()
  update_subscription()
});

import CableReady from 'cable_ready'
import consumer from './consumer'

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

// subscribe once when the page loads, and again whenever turbolinks sends the load message

subscribe()

document.addEventListener("turbolinks:load", function() {
  console.log('turboLOAD')
  subscribe()
});
import CableReady from 'cable_ready'
import consumer from './consumer'

consumer.subscriptions.create(
  {
    channel: 'GameChannel',
    id: document.URL.substring(document.URL.lastIndexOf('/') + 1)
  },
  {
    received (data) {
      console.log('yeehaw')
      if (data.cableReady) CableReady.perform(data.operations)
    }
  }
)
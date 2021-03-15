import ApplicationController from './application_controller'

import { Controller } from 'stimulus'
import CableReady from 'cable_ready'

export default class extends Controller {

  connect() {
    /*console.log(id)
    this.channel = this.application.consumer.subscriptions.create(
      {
        channel: 'GameChannel',
        id: this.id
      },
      {
        received (data) { if (data.cableReady) CableReady.perform(data.operations) }
      }
    )*/
  }

  disconnect() {
    this.channel.unsubscribe()
  }
}
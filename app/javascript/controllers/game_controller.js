import ApplicationController from './application_controller'

import { Controller } from 'stimulus'
import CableReady from 'cable_ready'
import {update_subscription} from '../channels/game_channel'

export default class extends ApplicationController {
  send_message(event) {
    if(event.keyCode === 13) {
      let message = document.getElementById('message-box').value
      document.getElementById('message-box').value = ''
      this.stimulate('Board#send_message', message)
    }
  }

  // if we successfully join the game, update subscription to the new player
  joinSuccess() {
    update_subscription()
  }
}
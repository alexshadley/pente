import ApplicationController from './application_controller'

import { Controller } from 'stimulus'
import CableReady from 'cable_ready'

export default class extends ApplicationController {
  send_message(event) {
    if(event.keyCode === 13) {
      let message = document.getElementById('message-box').value
      document.getElementById('message-box').value = ''
      this.stimulate('Board#send_message', message)
    }
  }
}
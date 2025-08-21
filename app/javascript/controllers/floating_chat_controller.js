// app/javascript/controllers/floating_chat_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    // console.log("Floating chat controller connected")
  }

  open(event) {
    event.preventDefault()
    this.panelTarget.classList.remove("hidden")
  }

  close(event) {
    event.preventDefault()
    this.panelTarget.classList.add("hidden")
  }
}

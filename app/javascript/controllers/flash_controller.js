import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  static values = { timeout: { type: Number, default: 4000 } }

  connect() {
    setTimeout(() => {
      this.element.classList.add("hidden")
    }, this.timeoutValue)
  }

  dismiss() {
    this.element.classList.add("hidden")
  }
}

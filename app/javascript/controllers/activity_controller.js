// app/javascript/controllers/activity_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.active = true
    this.setupListeners()
    this.startHeartbeat()
  }

  setupListeners() {
    document.addEventListener("visibilitychange", () => {
      this.active = !document.hidden
    })
  }

  startHeartbeat() {
    this.timer = setInterval(() => {
      if (this.active && document.hasFocus()) {
        this.sendPing()
      }
    }, 30000)
  }

  sendPing() {
    fetch("/activity_logs", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name=csrf-token]").content
      },
      body: JSON.stringify({ seconds: 30 })
    })
  }

  disconnect() {
    clearInterval(this.timer)
  }
}
